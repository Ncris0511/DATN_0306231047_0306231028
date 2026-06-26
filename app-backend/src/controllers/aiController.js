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

    const rawMedia = file_base64 || image_base64;
    const rawMime = file_mime_type || (image_base64 ? "image/jpeg" : null);

    // SIÊU PROMPT 7 TRƯỜNG: ÉP AI TỰ CHẤM ĐIỂM TIN CẬY KHÁCH QUAN
    const prompt = `
        Bạn là chuyên gia Thẩm định Ngôn ngữ học kiêm Giám định viên Tài liệu & Sản phẩm.
        Hãy đọc bình luận sau: "${noi_dung}"
        ${rawMedia ? "(LƯU Ý QUAN TRỌNG: Người dùng có đính kèm một Tệp tài liệu / Hình ảnh bên dưới. Hãy đọc/quan sát thật kỹ nội dung bên trong tệp này để đối chiếu với lời bình luận, phát hiện mâu thuẫn hoặc xác minh bằng chứng!)" : ""}

        Nhiệm vụ của bạn là trả về STRICTLY JSON thô (tuyệt đối không bọc markdown \`\`\`), gồm đúng 7 trường:
        {
          "nhan_cam_xuc": "TICH_CUC" hoặc "TIEU_CUC" hoặc "CHUA_PHAN_LOAI",
          "danh_gia_sao": số nguyên từ 1 đến 5,
          "diem_tin_cay_ai": số thập phân từ 0.10 đến 0.99 (Đánh giá khách quan: Câu dài, tường minh, có logic hoặc khớp ảnh đính kèm thì chấm cao >0.90; câu cụt lủn hoặc ảnh không liên quan thì chấm thấp <0.60),
          "tieu_chi_tin_cay": "Giải thích ngắn gọn căn cứ ngữ nghĩa và vật lý giúp bạn ra con số tin cậy này",
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

    // [ĐÃ TỐI ƯU]: Lấy trực tiếp điểm tin cậy thực tế do AI suy luận ra
    const doTinCay = parseFloat(aiOutput.diem_tin_cay_ai) || 0.85;

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
      data: { id: binhLuan.id, ...aiOutput, do_tin_cay: doTinCay, thoiGianMs },
    });
  } catch (error) {
    console.error("❌ Lỗi AI Controller:", error);
    return res
      .status(500)
      .json({ success: false, message: "Lỗi máy chủ phân tích AI" });
  }
};
