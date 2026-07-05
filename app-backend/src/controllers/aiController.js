const { GoogleGenerativeAI } = require("@google/generative-ai");
const db = require("../config/db");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

function base64ToGenerativePart(base64String, mimeType) {
  return { inlineData: { data: base64String.replace(/^data:.*?;base64,/, ""), mimeType: mimeType || "image/jpeg" } };
}

exports.phanTichBinhLuan = async (req, res) => {
  try {
    const { noi_dung, id_chu_de, hinh_anh_dinh_kem, image_base64, file_base64, file_mime_type, file_name } = req.body;
    if (!noi_dung) return res.status(400).json({ success: false, message: "Vui lòng nhập nội dung bình luận!" });

    const startTime = Date.now();
    const model = genAI.getGenerativeModel({ model: "gemini-3.5-flash", generationConfig: { responseMimeType: "application/json" } });

    const rawMedia = file_base64 || image_base64;
    const rawMime = file_mime_type || (image_base64 ? "image/jpeg" : null);

    // [MỚI]: THÊM YÊU CẦU LÝ DO SAO VÀO PROMPT
    const prompt = `
        Bạn là chuyên gia Thẩm định Ngôn ngữ học. Đọc bình luận sau: "${noi_dung}"
        ${rawMedia ? "(LƯU Ý: Người dùng có đính kèm Tệp/Hình ảnh. Hãy đối chiếu nội dung trong tệp với bình luận)" : ""}

        Nhiệm vụ: Phân tích và trả về cấu trúc JSON gồm các trường sau:
        {
          "nhan_cam_xuc": "TICH_CUC" hoặc "TIEU_CUC" hoặc "CHUA_PHAN_LOAI",
          "danh_gia_sao": số nguyên từ 1 đến 5,
          "ly_do_danh_gia_sao": "Giải thích thật chi tiết tại sao lại cho số sao này. Trích dẫn từ ngữ của khách để làm bằng chứng (VD: Cho 5 sao vì khách dùng từ 'tuyệt vời', 'chắc chắn mua lại')",
          "diem_tin_cay_ai": số thập phân từ 0.10 đến 0.99,
          "tieu_chi_tin_cay": "Căn cứ ngữ nghĩa",
          "sua_loi_chinh_ta": "Gợi ý sửa lỗi chính tả",
          "ly_do_ai_cham": "Tóm tắt lập luận",
          "danh_sach_khia_canh": [ { "ten_khia_canh": "Chung", "nhan_cam_xuc": "TRUNG_LAP", "trich_dan_goc": "" } ]
        }`;

    let aiOutput = null;
    let soLanThu = 0;
    const requestPayload = [prompt];
    if (rawMedia && rawMime) requestPayload.push(base64ToGenerativePart(rawMedia, rawMime));

    while (soLanThu < 3) {
      try {
        soLanThu++;
        const result = await model.generateContent(requestPayload);
        const jsonMatch = result.response.text().match(/\{[\s\S]*\}/);
        if (jsonMatch) { aiOutput = JSON.parse(jsonMatch[0]); break; } 
        else throw new Error("AI không trả về JSON hợp lệ");
      } catch (err) {
        console.error(`❌ Lỗi gọi Gemini lần ${soLanThu}:`, err.message);
        if (soLanThu < 3) await wait(2000);
      }
    }

    if (!aiOutput) return res.status(503).json({ success: false, message: "Lỗi gọi API Gemini." });

    const thoiGianMs = Date.now() - startTime;
    const danhGiaSao = Math.min(Math.max(parseInt(aiOutput.danh_gia_sao) || 3, 1), 5);
    const doTinCay = parseFloat(aiOutput.diem_tin_cay_ai) || 0.85;

    const binhLuan = await db.BinhLuan.create({
      id_chu_de: id_chu_de || 1,
      noi_dung,
      hinh_anh_dinh_kem: hinh_anh_dinh_kem || file_name || (rawMedia ? "tep_dinh_kem" : null),
      nhan_cam_xuc: aiOutput.nhan_cam_xuc || "CHUA_PHAN_LOAI",
      danh_gia_sao: danhGiaSao,
      ly_do_danh_gia_sao: aiOutput.ly_do_danh_gia_sao || "", // LƯU VÀO DB
      do_tin_cay: doTinCay,
      tieu_chi_tin_cay: aiOutput.tieu_chi_tin_cay,
      sua_loi_chinh_ta: aiOutput.sua_loi_chinh_ta,
      ly_do_ai_cham: aiOutput.ly_do_ai_cham,
      thoi_gian_xu_ly_ms: thoiGianMs,
      ai_version: "gemini-3.5-flash",
    });

    if (aiOutput.danh_sach_khia_canh?.length > 0) {
      const khiaCanhData = aiOutput.danh_sach_khia_canh.map((kc) => ({
        id_binh_luan: binhLuan.id, ten_khia_canh: kc.ten_khia_canh || "Chung", nhan_cam_xuc: kc.nhan_cam_xuc || "TRUNG_LAP", trich_dan_goc: kc.trich_dan_goc || "",
      }));
      await db.ChiTietKhiaCanh.bulkCreate(khiaCanhData);
    }

    return res.status(200).json({ success: true, data: { id: binhLuan.id, ...aiOutput, do_tin_cay: doTinCay, thoiGianMs } });
  } catch (error) {
    return res.status(500).json({ success: false, message: `Lỗi Database: ${error.message}` });
  }
};