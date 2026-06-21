const { GoogleGenerativeAI } = require("@google/generative-ai");
const db = require("../config/db");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

exports.phanTichBinhLuan = async (req, res) => {
  try {
    const { noi_dung } = req.body;
    if (!noi_dung)
      return res
        .status(400)
        .json({ success: false, message: "Vui lòng nhập bình luận!" });

    const startTime = Date.now();

    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

    const prompt = `
        Bạn là một chuyên gia thẩm định ngôn ngữ học kiêm nhân viên kiểm duyệt đánh giá. Hãy đọc kỹ câu sau: "${noi_dung}"

        Nhiệm vụ của bạn là trả về strictly JSON thô (tuyệt đối không bọc trong ký tự markdown \`\`\` ở đầu hay cuối), gồm đúng 3 trường:
        {
          "nhan_cam_xuc": "TICH_CUC" hoặc "TIEU_CUC" hoặc "CHUA_PHAN_LOAI",
          "danh_gia_sao": số nguyên từ 1 đến 5,
          "ly_do_ai_cham": "..."
        }

        QUY TẮC BẮT BUỘC KHI VIẾT 'ly_do_ai_cham' (Phải lập luận chặt chẽ như một biên bản chấm thi):
        1. PHẢI CÓ BẰNG CHỨNG: Trích dẫn lại đúng từ khóa/cụm từ quyết định trong câu.
        2. PHẢI GIẢI THÍCH LOGIC CỘNG/TRỪ SAO:
           - Nếu cho 5 sao: Phải khẳng định câu này "hoàn hảo, không có điểm cấn".
           - Nếu cho 4, 3, 2 sao: BẮT BUỘC phải giải thích vì sao bị trừ sao (Ví dụ: "Khách khen [A] nhưng vế sau chê [B] nên bị trừ 1 sao", hoặc "Sử dụng từ ngữ ba phải 'tạm được' thể hiện sự miễn cưỡng").
           - Nếu cho 1 sao: Chỉ ra từ ngữ bộc lộ sự phẫn nộ đỉnh điểm.
        3. Văn phong: Khách quan, chuyên nghiệp, đi thẳng vào vấn đề.
        `;

    let aiOutput = null;
    let soLanThu = 0;
    const maxLanThu = 3;

    while (soLanThu < maxLanThu) {
      try {
        soLanThu++;
        const result = await model.generateContent(prompt);
        const rawText = result.response.text().trim();
        const cleanText = rawText
          .replace(/```json/g, "")
          .replace(/```/g, "")
          .trim();

        aiOutput = JSON.parse(cleanText);
        break;
      } catch (err) {
        if (soLanThu < maxLanThu) {
          console.warn(
            `⚠️ [Google 503 - Thử lần ${soLanThu}/3]: Máy chủ đang kẹt, đợi 2s...`,
          );
          await wait(2000);
        }
      }
    }

    if (!aiOutput || !aiOutput.nhan_cam_xuc) {
      return res.status(503).json({
        success: false,
        message:
          "Hệ thống AI Google đang quá tải hàng đợi, vui lòng ấn gửi lại!",
      });
    }

    const thoiGianMs = Date.now() - startTime;
    const nhanCamXuc = ["TICH_CUC", "TIEU_CUC"].includes(aiOutput.nhan_cam_xuc)
      ? aiOutput.nhan_cam_xuc
      : "CHUA_PHAN_LOAI";
    const danhGiaSao = Math.min(
      Math.max(parseInt(aiOutput.danh_gia_sao) || 3, 1),
      5,
    );

    const bangHaiLong = {
      5: "Rất hài lòng",
      4: "Hài lòng",
      3: "Bình thường",
      2: "Thất vọng",
      1: "Rất thất vọng",
    };
    const mucDoHaiLong = bangHaiLong[danhGiaSao];

    const doTinCay =
      danhGiaSao === 5 || danhGiaSao === 1
        ? 0.965
        : danhGiaSao === 4 || danhGiaSao === 2
          ? 0.885
          : 0.75;

    const binhLuan = await db.BinhLuan.create({
      noi_dung,
      nhan_cam_xuc: nhanCamXuc,
      danh_gia_sao: danhGiaSao,
      muc_do_hai_long: mucDoHaiLong,
      do_tin_cay: doTinCay,
    });

    await db.NhatKyAI.create({
      id_binh_luan: binhLuan.id,
      thoi_gian_phan_hoi_ms: thoiGianMs,
      trang_thai_api: "THANH_CONG",
    });

    return res.status(200).json({
      success: true,
      data: {
        id: binhLuan.id,
        noi_dung,
        nhanCamXuc,
        danhGiaSao,
        mucDoHaiLong,
        doTinCay,
        lyDoCuaAI: aiOutput.ly_do_ai_cham,
        thoiGianMs,
        ai_version: "gemini-2.5-flash",
      },
    });
  } catch (error) {
    console.error("❌ Lỗi AI Controller:", error);
    return res
      .status(500)
      .json({ success: false, message: "Lỗi máy chủ phân tích AI" });
  }
};
