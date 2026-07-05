const db = require("../config/db");
const { GoogleGenerativeAI } = require("@google/generative-ai");

exports.taoChuDeMoi = async (req, res) => {
  try {
    const { id_tai_khoan, ten_chu_de } = req.body;
    const chuDe = await db.ChuDePhanTich.create({
      id_tai_khoan,
      ten_chu_de,
      phan_quyet_ai: "CHUA_HOI_CHAN",
    });
    return res.status(201).json({ success: true, data: chuDe });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Không thể tạo chủ đề mới" });
  }
};

exports.layDanhSachSidebar = async (req, res) => {
  try {
    const { id_tai_khoan } = req.query;
    const danhSach = await db.ChuDePhanTich.findAll({
      where: { id_tai_khoan },
      order: [["ngay_tao", "DESC"]],
    });

    const dataWithCount = await Promise.all(
      danhSach.map(async (item) => {
        const soLuong = await db.BinhLuan.count({
          where: { id_chu_de: item.id },
        });
        return { ...item.dataValues, so_luong_binh_luan: soLuong };
      }),
    );
    return res.status(200).json({ success: true, tong_so_topic: dataWithCount.length, data: dataWithCount });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Lỗi tải danh sách Sidebar" });
  }
};

exports.layChiTietPhienChat = async (req, res) => {
  try {
    const { id } = req.params;
    const chuDe = await db.ChuDePhanTich.findByPk(id);
    if (!chuDe) return res.status(404).json({ success: false, message: "Không tìm thấy phiên này!" });

    const lichSu = await db.BinhLuan.findAll({
      where: { id_chu_de: id },
      include: [{ model: db.ChiTietKhiaCanh, as: "danhSachKhiaCanh" }],
      order: [["ngay_tao", "ASC"]],
    });
    return res.status(200).json({ success: true, thong_tin_topic: chuDe, lich_su_hoi_thoai: lichSu });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Lỗi tải chi tiết trò chuyện" });
  }
};

exports.xoaTopic = async (req, res) => {
  try {
    const { id } = req.params;
    const { id_tai_khoan } = req.query;
    const chuDe = await db.ChuDePhanTich.findOne({
      where: { id, id_tai_khoan },
    });
    if (!chuDe) return res.status(404).json({ success: false, message: "Không có quyền xóa topic này!" });

    await chuDe.destroy();
    return res.status(200).json({ success: true, message: "Đã xóa vĩnh viễn phiên phân tích!" });
  } catch (error) {
    return res.status(500).json({ success: false });
  }
};

exports.hoiChanAI = async (req, res) => {
  try {
    const { id } = req.params;
    const topic = await db.ChuDePhanTich.findByPk(id);
    if (!topic) return res.status(404).json({ success: false, message: "Không tìm thấy chủ đề!" });

    const dsBinhLuan = await db.BinhLuan.findAll({
      where: { id_chu_de: id },
      attributes: ["noi_dung", "danh_gia_sao"],
    });
    
    if (dsBinhLuan.length === 0) return res.status(400).json({ success: false, message: "Chưa có bình luận nào để hội chẩn!" });

    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    
    // ĐÃ NÂNG CẤP LÊN BẢN TỐI TÂN NHẤT: GEMINI 3.5 FLASH
    const model = genAI.getGenerativeModel({ 
        model: "gemini-3.5-flash",
        generationConfig: { responseMimeType: "application/json" }
    });

    const gopText = dsBinhLuan.map((item, idx) => `[Comment ${idx + 1} - ${item.danh_gia_sao} Sao]: "${item.noi_dung}"`).join("\n");
    const prompt = `
        Bạn là Giám đốc Thẩm định Sản phẩm. Dưới đây là ${dsBinhLuan.length} bình luận về: "${topic.ten_chu_de}"
        ${gopText}
        Trả về strictly JSON thô:
        {
          "phan_quyet": "APPROVED_NEN_MUA" hoặc "CAUTION_CAN_NHAC",
          "tom_tat": "2 câu tiếng Việt: Câu 1 nêu ưu điểm nổi bật nhất, Câu 2 chỉ ra nhược điểm lớn nhất hoặc lời khuyên mua sắm."
        }`;

    const result = await model.generateContent(prompt);
    const rawText = result.response.text();
    
    // BỌC THÉP CHỐNG LỖI JSON
    const jsonMatch = rawText.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error("AI không trả về JSON");
    const aiOutput = JSON.parse(jsonMatch[0]);

    topic.phan_quyet_ai = aiOutput.phan_quyet || "CAUTION_CAN_NHAC";
    topic.tom_tat_ai = aiOutput.tom_tat || "Hội chẩn hoàn tất.";
    await topic.save();

    return res.status(200).json({ success: true, ket_qua_chot_ha: topic });
  } catch (error) {
    console.error("❌ Lỗi Hội Chẩn:", error);
    return res.status(500).json({ success: false, message: `Lỗi máy chủ hội chẩn AI: ${error.message}` });
  }
};