const db = require("../config/db");
const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// ⏳ VŨ KHÍ MỚI: HÀM ÉP THỜI GIAN (TIMEOUT) CHO HỘI CHẨN
const executeWithTimeout = (promise, timeoutMs) => {
  return Promise.race([
    promise,
    new Promise((_, reject) =>
      setTimeout(() => reject(new Error("GOOGLE_HANGING_TIMEOUT")), timeoutMs),
    ),
  ]);
};

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
    return res
      .status(500)
      .json({ success: false, message: "Không thể tạo chủ đề mới" });
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
    return res
      .status(200)
      .json({
        success: true,
        tong_so_topic: dataWithCount.length,
        data: dataWithCount,
      });
  } catch (error) {
    return res
      .status(500)
      .json({ success: false, message: "Lỗi tải danh sách Sidebar" });
  }
};

exports.layChiTietPhienChat = async (req, res) => {
  try {
    const { id } = req.params;
    const chuDe = await db.ChuDePhanTich.findByPk(id);
    if (!chuDe)
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy phiên này!" });

    const lichSu = await db.BinhLuan.findAll({
      where: { id_chu_de: id },
      include: [{ model: db.ChiTietKhiaCanh, as: "danhSachKhiaCanh" }],
      order: [["ngay_tao", "ASC"]],
    });
    return res
      .status(200)
      .json({
        success: true,
        thong_tin_topic: chuDe,
        lich_su_hoi_thoai: lichSu,
      });
  } catch (error) {
    return res
      .status(500)
      .json({ success: false, message: "Lỗi tải chi tiết trò chuyện" });
  }
};

exports.xoaTopic = async (req, res) => {
  try {
    const { id } = req.params;
    const { id_tai_khoan } = req.query;
    const chuDe = await db.ChuDePhanTich.findOne({
      where: { id, id_tai_khoan },
    });
    if (!chuDe)
      return res
        .status(404)
        .json({ success: false, message: "Không có quyền xóa topic này!" });

    await chuDe.destroy();
    return res
      .status(200)
      .json({ success: true, message: "Đã xóa vĩnh viễn phiên phân tích!" });
  } catch (error) {
    return res.status(500).json({ success: false });
  }
};

// =========================================================================
// ĐÃ ĐẠI TU TOÀN DIỆN: CHỐNG TREO, CHỐNG QUÁ TẢI, TỰ ĐỘNG LÙI MODEL
// =========================================================================
exports.hoiChanAI = async (req, res) => {
  try {
    const { id } = req.params;
    const topic = await db.ChuDePhanTich.findByPk(id);
    if (!topic)
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy chủ đề!" });

    const dsBinhLuan = await db.BinhLuan.findAll({
      where: { id_chu_de: id },
      attributes: ["noi_dung", "danh_gia_sao"],
    });

    if (dsBinhLuan.length === 0)
      return res
        .status(400)
        .json({
          success: false,
          message: "Chưa có bình luận nào để hội chẩn!",
        });

    const gopText = dsBinhLuan
      .map(
        (item, idx) =>
          `[Comment ${idx + 1} - ${item.danh_gia_sao} Sao]: "${item.noi_dung}"`,
      )
      .join("\n");
    const prompt = `
        Bạn là Giám đốc Thẩm định Sản phẩm. Dưới đây là ${dsBinhLuan.length} bình luận về: "${topic.ten_chu_de}"
        ${gopText}
        Trả về strictly JSON thô:
        {
          "phan_quyet": "APPROVED_NEN_MUA" hoặc "CAUTION_CAN_NHAC",
          "tom_tat": "2 câu tiếng Việt: Câu 1 nêu ưu điểm nổi bật nhất, Câu 2 chỉ ra nhược điểm lớn nhất hoặc lời khuyên mua sắm."
        }`;

    const danhSachModel = [
      "gemini-3.5-flash",
      "gemini-2.5-flash",
      "gemini-pro",
    ];
    let aiOutput = null;

    for (const tenModel of danhSachModel) {
      console.log(`🚀 [HỘI CHẨN] Đang khởi động AI Model: ${tenModel}...`);
      const currentModel = genAI.getGenerativeModel({
        model: tenModel,
        generationConfig: { responseMimeType: "application/json" },
      });

      let soLanThu = 0;
      let thanhCong = false;

      while (soLanThu < 2) {
        try {
          soLanThu++;

          // BẮT BUỘC TRẢ LỜI TRONG 15 GIÂY, KHÔNG ĐƯỢC NGÂM!
          const result = await executeWithTimeout(
            currentModel.generateContent(prompt),
            15000,
          );

          const rawText = result.response.text();
          const jsonMatch = rawText.match(/\{[\s\S]*\}/);

          if (jsonMatch) {
            aiOutput = JSON.parse(jsonMatch[0]);
            thanhCong = true;
            console.log(
              `✅ [HỘI CHẨN] Thành công mỹ mãn với bản: ${tenModel}!`,
            );
            break;
          } else {
            throw new Error("AI không trả về JSON hợp lệ");
          }
        } catch (err) {
          if (err.message === "GOOGLE_HANGING_TIMEOUT") {
            console.log(
              `⏱️ [HỘI CHẨN] Model ${tenModel} bị treo quá 15 giây! Bỏ qua ngay lập tức!`,
            );
            break;
          }

          console.error(
            `❌ Lỗi Hội Chẩn ${tenModel} (Lần ${soLanThu}):`,
            err.message,
          );

          if (
            err.message.includes("404") ||
            err.message.includes("not found")
          ) {
            console.log(
              `⏭️ [HỘI CHẨN] Model ${tenModel} bị khóa (404). Chuyển gấp sang dự phòng!`,
            );
            break;
          }

          if (soLanThu < 2) {
            console.log(`⏳ Đang chờ 3s để Google xả tải...`);
            await wait(3000);
          }
        }
      }

      if (thanhCong) break;
    }

    // NẾU TẤT CẢ MODEL ĐỀU SẬP -> TỰ ĐỘNG ĐƯA RA KẾT QUẢ ĐỂ KHÔNG CHẾT APP
    if (!aiOutput) {
      console.log(
        "⚠️ Tất cả model đều thất bại. Kích hoạt kết quả Hội chẩn Khẩn cấp.",
      );
      aiOutput = {
        phan_quyet: "CAUTION_CAN_NHAC",
        tom_tat:
          "Hệ thống AI hiện đang quá tải và không thể đưa ra lời khuyên chi tiết lúc này. Vui lòng dựa vào biểu đồ cảm xúc để tự đưa ra quyết định.",
      };
    }

    topic.phan_quyet_ai = aiOutput.phan_quyet || "CAUTION_CAN_NHAC";
    topic.tom_tat_ai = aiOutput.tom_tat || "Hội chẩn hoàn tất.";
    await topic.save();

    return res.status(200).json({ success: true, ket_qua_chot_ha: topic });
  } catch (error) {
    console.error("❌ Lỗi Hệ thống Hội Chẩn:", error);
    return res
      .status(500)
      .json({
        success: false,
        message: `Lỗi máy chủ hội chẩn AI: ${error.message}`,
      });
  }
};
