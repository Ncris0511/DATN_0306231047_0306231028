const { GoogleGenerativeAI } = require("@google/generative-ai");
const db = require("../config/db");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

function base64ToGenerativePart(base64String, mimeType) {
  return {
    inlineData: {
      data: base64String.replace(/^data:.*?;base64,/, ""),
      mimeType: mimeType || "image/jpeg",
    },
  };
}

// ⏳ VŨ KHÍ MỚI: HÀM ÉP THỜI GIAN (TIMEOUT)
// Chạy đua giữa việc gọi API và thời gian đếm ngược. Ai xong trước lấy kết quả đó!
const executeWithTimeout = (promise, timeoutMs) => {
  return Promise.race([
    promise,
    new Promise((_, reject) =>
      setTimeout(() => reject(new Error("GOOGLE_HANGING_TIMEOUT")), timeoutMs),
    ),
  ]);
};

exports.phanTichBinhLuan = async (req, res) => {
  try {
    const {
      noi_dung,
      id_chu_de,
      hinh_anh_dinh_kem,
      image_base64,
      file_base64,
      file_mime_type,
      file_name,
    } = req.body;
    if (!noi_dung)
      return res
        .status(400)
        .json({ success: false, message: "Vui lòng nhập nội dung bình luận!" });

    const startTime = Date.now();
    const rawMedia = file_base64 || image_base64;
    const rawMime = file_mime_type || (image_base64 ? "image/jpeg" : null);

    const prompt = `
        Bạn là chuyên gia Thẩm định Ngôn ngữ học. Đọc bình luận sau: "${noi_dung}"
        ${rawMedia ? "(LƯU Ý: Người dùng có đính kèm Tệp/Hình ảnh. Hãy đối chiếu nội dung trong tệp với bình luận)" : ""}

        Nhiệm vụ: Phân tích và trả về cấu trúc JSON gồm các trường sau:
        {
          "nhan_cam_xuc": "TICH_CUC" hoặc "TIEU_CUC" hoặc "CHUA_PHAN_LOAI",
          "danh_gia_sao": số nguyên từ 1 đến 5,
          "ly_do_danh_gia_sao": "Giải thích thật chi tiết tại sao lại cho số sao này.",
          "diem_tin_cay_ai": số thập phân từ 0.10 đến 0.99,
          "tieu_chi_tin_cay": "Căn cứ ngữ nghĩa",
          "sua_loi_chinh_ta": "Gợi ý sửa lỗi chính tả",
          "ly_do_ai_cham": "Tóm tắt lập luận",
          "danh_sach_khia_canh": [ { "ten_khia_canh": "Chung", "nhan_cam_xuc": "TRUNG_LAP", "trich_dan_goc": "" } ]
        }`;

    const requestPayload = [prompt];
    if (rawMedia && rawMime)
      requestPayload.push(base64ToGenerativePart(rawMedia, rawMime));

    // DANH SÁCH MODEL QUÉT DẦN
    const danhSachModel = [
      "gemini-3.5-flash",
      "gemini-2.5-flash",
      "gemini-pro",
    ];
    let aiOutput = null;
    let usedVersion = "";

    for (const tenModel of danhSachModel) {
      console.log(`🚀 Đang khởi động AI Model: ${tenModel}...`);
      const currentModel = genAI.getGenerativeModel({
        model: tenModel,
        generationConfig: { responseMimeType: "application/json" },
      });

      let soLanThu = 0;
      let thanhCong = false;

      while (soLanThu < 2) {
        try {
          soLanThu++;

          // 🔥 ÁP DỤNG ÉP THỜI GIAN: Bắt buộc Google phải trả lời trong vòng 15 giây (15000ms)!
          const result = await executeWithTimeout(
            currentModel.generateContent(requestPayload),
            15000,
          );

          const jsonMatch = result.response.text().match(/\{[\s\S]*\}/);

          if (jsonMatch) {
            aiOutput = JSON.parse(jsonMatch[0]);
            usedVersion = tenModel;
            thanhCong = true;
            break;
          } else {
            throw new Error("AI không trả về JSON hợp lệ");
          }
        } catch (err) {
          // XỬ LÝ LỖI TREO (TIMEOUT)
          if (err.message === "GOOGLE_HANGING_TIMEOUT") {
            console.log(
              `⏱️ Model ${tenModel} bị treo quá 15 giây! Bỏ qua ngay lập tức!`,
            );
            break; // Cắt đuôi ngay, nhảy sang Model tiếp theo trong danh sách
          }

          console.error(
            `❌ Lỗi gọi ${tenModel} (Lần ${soLanThu}):`,
            err.message,
          );

          // XỬ LÝ LỖI 404 (Không tồn tại)
          if (
            err.message.includes("404") ||
            err.message.includes("not found")
          ) {
            console.log(
              `⏭️ Model ${tenModel} bị khóa (404). Chuyển gấp sang dự phòng!`,
            );
            break;
          }

          // XỬ LÝ LỖI 503 (Quá tải)
          if (soLanThu < 2) {
            console.log(`⏳ Đang chờ 3s để Google xả tải...`);
            await wait(3000);
          }
        }
      }

      if (thanhCong) break;
    }

    if (!aiOutput)
      return res
        .status(503)
        .json({
          success: false,
          message:
            "Toàn bộ hệ thống AI đang quá tải. Vui lòng thử lại sau ít phút!",
        });

    const thoiGianMs = Date.now() - startTime;
    const danhGiaSao = Math.min(
      Math.max(parseInt(aiOutput.danh_gia_sao) || 3, 1),
      5,
    );
    const doTinCay = parseFloat(aiOutput.diem_tin_cay_ai) || 0.85;

    const binhLuan = await db.BinhLuan.create({
      id_chu_de: id_chu_de || 1,
      noi_dung,
      hinh_anh_dinh_kem:
        hinh_anh_dinh_kem || file_name || (rawMedia ? "tep_dinh_kem" : null),
      nhan_cam_xuc: aiOutput.nhan_cam_xuc || "CHUA_PHAN_LOAI",
      danh_gia_sao: danhGiaSao,
      ly_do_danh_gia_sao: aiOutput.ly_do_danh_gia_sao || "",
      do_tin_cay: doTinCay,
      tieu_chi_tin_cay: aiOutput.tieu_chi_tin_cay,
      sua_loi_chinh_ta: aiOutput.sua_loi_chinh_ta,
      ly_do_ai_cham: aiOutput.ly_do_ai_cham,
      thoi_gian_xu_ly_ms: thoiGianMs,
      ai_version: usedVersion,
    });

    if (aiOutput.danh_sach_khia_canh?.length > 0) {
      const khiaCanhData = aiOutput.danh_sach_khia_canh.map((kc) => ({
        id_binh_luan: binhLuan.id,
        ten_khia_canh: kc.ten_khia_canh || "Chung",
        nhan_cam_xuc: kc.nhan_cam_xuc || "TRUNG_LAP",
        trich_dan_goc: kc.trich_dan_goc || "",
      }));
      await db.ChiTietKhiaCanh.bulkCreate(khiaCanhData);
    }
    console.log(`✅ Phân tích thành công mỹ mãn bằng bản: ${usedVersion}! Đã gửi kết quả về App.`);
    return res.status(200).json({
      success: true,
      data: {
        id: binhLuan.id,
        noi_dung: noi_dung,
        hinh_anh_dinh_kem: binhLuan.hinh_anh_dinh_kem,
        ...aiOutput,
        do_tin_cay: doTinCay,
        thoiGianMs,
      },
    });
  } catch (error) {
    return res
      .status(500)
      .json({ success: false, message: `Lỗi Database: ${error.message}` });
  }
};
