const db = require('../config/db');

exports.layDashboard = async (req, res) => {
    try {
        const tong = await db.BinhLuan.count();
        const tichCuc = await db.BinhLuan.count({ where: { nhan_cam_xuc: 'TICH_CUC' } });
        const tieuCuc = await db.BinhLuan.count({ where: { nhan_cam_xuc: 'TIEU_CUC' } });
        
        const logAI = await db.NhatKyAI.findAll({ attributes: [[db.sequelize.fn('AVG', db.sequelize.col('thoi_gian_phan_hoi_ms')), 'avg_time']] });
        const thoiGianTB = logAI[0].dataValues.avg_time ? Math.round(logAI[0].dataValues.avg_time) : 0;

        return res.json({ success: true, data: { tong_binh_luan: tong, tich_cuc: tichCuc, tieu_cuc: tieuCuc, thoi_gian_tb_ms: thoiGianTB } });
    } catch (error) {
        return res.status(500).json({ success: false });
    }
};