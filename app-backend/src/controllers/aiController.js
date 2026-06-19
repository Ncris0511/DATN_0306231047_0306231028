const { GoogleGenerativeAI } = require("@google/generative-ai");
const db = require("../config/db");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

exports.phanTichBinhLuan = async (req, res) => {
  try {
    const { noi_dung } = req.body;
    if (!noi_dung)
      return res
        .status(400)
        .json({ success: false, message: "Nhập bình luận" });

    const startTime = Date.now();
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
    const result = await model.generateContent(
      `Phân tích cảm xúc câu sau, chỉ trả về TICH_CUC, TIEU_CUC, hoặc CHUA_PHAN_LOAI: "${noi_dung}"`,
    );

    let nhanCamXuc = result.response.text().trim().toUpperCase();
    if (!["TICH_CUC", "TIEU_CUC", "CHUA_PHAN_LOAI"].includes(nhanCamXuc))
      nhanCamXuc = "CHUA_PHAN_LOAI";

    const thoiGianMs = Date.now() - startTime;

    let danhGiaSao = 3,
      mucDoHaiLong = "Bình thường",
      doTinCay = 0.5;
    if (nhanCamXuc === "TICH_CUC") {
      danhGiaSao = 5;
      mucDoHaiLong = "Rất hài lòng";
      doTinCay = 0.95;
    } else if (nhanCamXuc === "TIEU_CUC") {
      danhGiaSao = 1;
      mucDoHaiLong = "Rất thất vọng";
      doTinCay = 0.92;
    }

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
    });

    return res.json({
      success: true,
      data: {
        id: binhLuan.id,
        noi_dung,
        nhanCamXuc,
        danhGiaSao,
        mucDoHaiLong,
        thoiGianMs,
      },
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: "Lỗi AI" });
  }
};
