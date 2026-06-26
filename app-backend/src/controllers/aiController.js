const { GoogleGenerativeAI } = require("@google/generative-ai");
const db = require("../config/db");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// Hàm đa năng: Tự động cắt mọi tiền tố Base64 của Ảnh, PDF, TXT, CSV...
function base64ToGenerativePart(base64String, mimeType) {
  return {
    inlineData: {
      data: base64String.replace(/^data:.*?;base64,/, ""), // Regex quét sạch mọi loại tiền tố file
      mimeType: mimeType || "image/jpeg",
    },
  };
}

exports.phanTichBinhLuan = async (req, res) => {
  try {
    // Nhận thêm file_base64, file_mime_type, file_name (Vẫn giữ image_base64 cũ để không gãy test Postman của bạn)
    const {
      noi_dung,
      id_chu_de,
      hinh_anh_dinh_kem,
      image_base64,
      file_base64,
      file_mime_type,
      file_name,
    } = req.body;

    if (!noi_dung) {
      return res
        .status(400)
        .json({ success: false, message: "Vui lòng nhập nội dung bình luận!" });
    }

    const startTime = Date.now();
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

    // Hợp nhất dữ liệu: gửi ảnh cũ hay gửi file mới đều gom vào 1 biến
    const rawMedia = file_base64 || image_base64;
    const rawMime = file_mime_type || (image_base64 ? "image/jpeg" : null);

    const prompt = `
        Bạn là chuyên gia Thẩm định Ngôn ngữ học kiêm Giám định viên Tài liệu & Sản phẩm.
        Hãy đọc bình luận sau: "${noi_dung}"
        ${rawMedia ? "(LƯU Ý QUAN TRỌNG: Người dùng có đính kèm một Tệp tài liệu / Hình ảnh bên dưới. Hãy đọc/quan sát thật kỹ nội dung bên trong tệp này để đối chiếu với lời bình luận, phát hiện mâu thuẫn hoặc xác minh bằng chứng!)" : ""}

        Nhiệm vụ của bạn là trả về STRICTLY JSON thô (tuyệt đối không bọc markdown \`\`\`), gồm đúng 6 trường:
        {
          "nhan_cam_xuc": "TICH_CUC" hoặc "TIEU_CUC" hoặc "CHUA_PHAN_LOAI",
          "danh_gia_sao": số nguyên từ 1 đến 5,
          "tieu_chi_tin_cay": "Giải thích ngắn gọn căn cứ ngữ nghĩa (và căn cứ từ Tệp đính kèm nếu có) giúp bạn ra kết luận",
          "sua_loi_chinh_ta": "Gợi ý sửa lỗi chính tả/từ lóng, hoặc ghi 'Không có lỗi'",
          "ly_do_ai_cham": "Tóm tắt lập luận tổng quan trong 1 câu",
          "danh_sach_khia_canh": [
             {
               "ten_khia_canh": "Tên khía cạnh (VD: Chất lượng sản phẩm, Thái độ hỗ trợ, Bằng chứng tài liệu...)",
               "nhan_cam_xuc": "TICH_CUC" hoặc "TIEU_CUC" hoặc "TRUNG_LAP",
               "trich_dan_goc": "Cắt từ khóa gốc làm bằng chứng"
             }
          ]
        }`;

    let aiOutput = null;
    let soLanThu = 0;

    const requestPayload = [prompt];
    if (rawMedia && rawMime) {
      requestPayload.push(base64ToGenerativePart(rawMedia, rawMime));
    }

    while (soLanThu < 3) {
      try {
        soLanThu++;
        const result = await model.generateContent(requestPayload);
        const cleanText = result.response
          .text()
          .replace(/```json/g, "")
          .replace(/```/g, "")
          .trim();
        aiOutput = JSON.parse(cleanText);
        break;
      } catch (err) {
        if (soLanThu < 3) await wait(2000);
      }
    }

    if (!aiOutput) {
      return res
        .status(503)
        .json({ success: false, message: "Hệ thống AI Google đang kẹt tải!" });
    }

    const thoiGianMs = Date.now() - startTime;
    const danhGiaSao = Math.min(
      Math.max(parseInt(aiOutput.danh_gia_sao) || 3, 1),
      5,
    );
    const doTinCay =
      danhGiaSao === 5 || danhGiaSao === 1
        ? 0.965
        : danhGiaSao === 4 || danhGiaSao === 2
          ? 0.885
          : 0.75;

    // Lưu DB tự động nhận diện tên file
    const tenFileLuu =
      hinh_anh_dinh_kem ||
      file_name ||
      (rawMedia ? "tep_dinh_kem_multimodal" : null);

    const binhLuan = await db.BinhLuan.create({
      id_chu_de: id_chu_de || 1,
      noi_dung,
      hinh_anh_dinh_kem: tenFileLuu,
      nhan_cam_xuc: aiOutput.nhan_cam_xuc || "CHUA_PHAN_LOAI",
      danh_gia_sao: danhGiaSao,
      do_tin_cay: doTinCay,
      tieu_chi_tin_cay: aiOutput.tieu_chi_tin_cay,
      sua_loi_chinh_ta: aiOutput.sua_loi_chinh_ta,
      ly_do_ai_cham: aiOutput.ly_do_ai_cham,
      thoi_gian_xu_ly_ms: thoiGianMs,
      ai_version: rawMedia ? "gemini-2.5-flash-multimodal" : "gemini-2.5-flash",
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

    return res.status(200).json({
      success: true,
      data: { id: binhLuan.id, ...aiOutput, thoiGianMs },
    });
  } catch (error) {
    console.error("❌ Lỗi AI Controller:", error);
    return res
      .status(500)
      .json({ success: false, message: "Lỗi máy chủ phân tích AI" });
  }
};
