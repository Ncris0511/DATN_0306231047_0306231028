const db = require("../config/db");

exports.layDashboard = async (req, res) => {
  try {
    const tong = await db.BinhLuan.count();
    if (tong === 0)
      return res.json({ success: true, data: { tong_binh_luan: 0 } });

    const tichCuc = await db.BinhLuan.count({
      where: { nhan_cam_xuc: "TICH_CUC" },
    });
    const tieuCuc = await db.BinhLuan.count({
      where: { nhan_cam_xuc: "TIEU_CUC" },
    });
    const trungLap = await db.BinhLuan.count({
      where: { nhan_cam_xuc: "CHUA_PHAN_LOAI" },
    });

    const promoters = await db.BinhLuan.count({ where: { danh_gia_sao: [5] } });
    const passives = await db.BinhLuan.count({
      where: { danh_gia_sao: [3, 4] },
    });
    const detractors = await db.BinhLuan.count({
      where: { danh_gia_sao: [1, 2] },
    });

    const diemNPS = Math.round(((promoters - detractors) / tong) * 100);

    let loiChanDoan =
      diemNPS >= 50
        ? "Xuất sắc: Khách hàng yêu thích!"
        : diemNPS >= 0
          ? "Cảnh báo: Dễ rời bỏ."
          : "Báo động đỏ!";
    let maMauHex =
      diemNPS >= 50 ? "0xFF4CAF50" : diemNPS >= 0 ? "0xFFFF9800" : "0xFFF44336";

    const logAI = await db.BinhLuan.findAll({
      attributes: [
        [
          db.sequelize.fn("AVG", db.sequelize.col("thoi_gian_xu_ly_ms")),
          "avg_time",
        ],
      ],
    });

    return res.json({
      success: true,
      data: {
        tong_binh_luan: tong,
        ai_nhan_dien: {
          tich_cuc: tichCuc,
          tieu_cuc: tieuCuc,
          trung_lap: trungLap,
        },
        chi_so_nps: {
          diem: diemNPS,
          chan_doan_suckhoe: loiChanDoan,
          mau_sac_ui: maMauHex,
        },
        thoi_gian_tb_ms: Math.round(logAI[0]?.dataValues.avg_time || 0),
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false });
  }
};
