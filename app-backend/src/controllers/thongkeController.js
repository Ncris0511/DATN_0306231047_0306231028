const db = require("../config/db");

exports.layDashboard = async (req, res) => {
  try {
    const tong = await db.BinhLuan.count();
    if (tong === 0) {
      return res.json({
        success: true,
        data: {
          tong_binh_luan: 0,
          nps: { diem: 0, chan_doan: "Chưa có dữ liệu" },
        },
      });
    }

    const tichCuc = await db.BinhLuan.count({
      where: { nhan_cam_xuc: "TICH_CUC" },
    });
    const tieuCuc = await db.BinhLuan.count({
      where: { nhan_cam_xuc: "TIEU_CUC" },
    });
    const trungLap = await db.BinhLuan.count({
      where: { nhan_cam_xuc: "CHUA_PHAN_LOAI" },
    });

    // Phân loại khách hàng theo chuẩn quốc tế Net Promoter Score (NPS)
    const promoters = await db.BinhLuan.count({ where: { danh_gia_sao: [5] } }); // Fan trung thành
    const passives = await db.BinhLuan.count({
      where: { danh_gia_sao: [3, 4] },
    }); // Khách vãng lai
    const detractors = await db.BinhLuan.count({
      where: { danh_gia_sao: [1, 2] },
    }); // Khách bực bội

    // Công thức NPS = (% Promoters) - (% Detractors)
    const diemNPS = Math.round(((promoters - detractors) / tong) * 100);

    // Chẩn đoán sức khỏe thương hiệu trả về cho Flutter đổi màu
    let loiChanDoan = "";
    let maMauHex = "";

    if (diemNPS >= 50) {
      loiChanDoan = "Xuất sắc: Khách hàng cực kỳ yêu thích và trung thành!";
      maMauHex = "0xFF4CAF50"; // Xanh lá Flutter
    } else if (diemNPS >= 20) {
      loiChanDoan = "Khá tốt: Tình hình khả quan, cần phát huy.";
      maMauHex = "0xFF2196F3"; // Xanh biển
    } else if (diemNPS >= 0) {
      loiChanDoan = "Cảnh báo: Khách hàng ở mức tạm chấp nhận, dễ rời bỏ.";
      maMauHex = "0xFFFF9800"; // Cam
    } else {
      loiChanDoan = "BÁO ĐỘNG KHẨN: Khách hàng đang phẫn nộ và quay lưng!";
      maMauHex = "0xFFF44336"; // Đỏ
    }

    // Lấy tốc độ phản hồi trung bình của AI
    const logAI = await db.NhatKyAI.findAll({
      attributes: [
        [
          db.sequelize.fn("AVG", db.sequelize.col("thoi_gian_phan_hoi_ms")),
          "avg_time",
        ],
      ],
    });
    const thoiGianTB = logAI[0]?.dataValues.avg_time
      ? Math.round(logAI[0].dataValues.avg_time)
      : 0;

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
          chi_tiet_nhom: { promoters, passives, detractors },
        },
        thoi_gian_tb_ms: thoiGianTB,
      },
    });
  } catch (error) {
    console.error("❌ Lỗi thống kê:", error);
    return res.status(500).json({ success: false });
  }
};
