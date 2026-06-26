const db = require("../config/db");
const xl = require("excel4node");

exports.loginAdmin = async (req, res) => {
  try {
    const { ten_dang_nhap, mat_khau } = req.body;
    const [users] = await db.sequelize.query(
      `SELECT id, ten_dang_nhap, ho_ten, vai_tro FROM tai_khoan WHERE ten_dang_nhap = :ten_dang_nhap AND mat_khau = :mat_khau AND vai_tro = 'quan_tri' LIMIT 1`,
      { replacements: { ten_dang_nhap, mat_khau } },
    );
    if (users.length === 0)
      return res
        .status(401)
        .json({ success: false, message: "Sai tài khoản Admin!" });
    return res.status(200).json({ success: true, data: users[0] });
  } catch (error) {
    return res.status(500).json({ success: false });
  }
};

exports.thongKeThoiGian = async (req, res) => {
  try {
    const { loc_theo } = req.query;
    const boLoc = [
      "hom_nay",
      "7_ngay",
      "thang_nay",
      "nam_nay",
      "tat_ca",
    ].includes(loc_theo)
      ? loc_theo
      : "7_ngay";
    let sql =
      boLoc === "hom_nay"
        ? `SELECT HOUR(ngay_tao) AS raw_unit, COUNT(*) AS tong_so FROM binh_luan WHERE DATE(ngay_tao) = DATE(NOW()) GROUP BY HOUR(ngay_tao)`
        : `SELECT DATE_FORMAT(ngay_tao, '%Y-%m-%d') AS raw_unit, COUNT(*) AS tong_so FROM binh_luan GROUP BY DATE_FORMAT(ngay_tao, '%Y-%m-%d')`;

    const [rows] = await db.sequelize.query(sql);
    const cleanData = rows.map((item) => ({
      mox: item.raw_unit,
      tong_so: parseInt(item.tong_so) || 0,
    }));
    return res
      .status(200)
      .json({ success: true, khung_thoi_gian: boLoc, data: cleanData });
  } catch (error) {
    return res.status(500).json({ success: false });
  }
};

exports.layDanhSachBinhLuan = async (req, res) => {
  try {
    const [rows] = await db.sequelize.query(
      `SELECT * FROM binh_luan ORDER BY ngay_tao DESC`,
    );
    return res.status(200).json({ success: true, data: rows });
  } catch (e) {
    return res.status(500).json({ success: false });
  }
};

exports.xuatBaoCao = async (req, res) => {
  try {
    const [rows] = await db.sequelize.query(
      `SELECT * FROM binh_luan ORDER BY ngay_tao DESC`,
    );
    const wb = new xl.Workbook();
    const ws = wb.addWorksheet("Báo cáo AI");

    const tuDienHaiLong = {
      5: "Rất hài lòng",
      4: "Hài lòng",
      3: "Bình thường",
      2: "Thất vọng",
      1: "Rất thất vọng",
    };

    rows.forEach((item, index) => {
      const r = index + 2;
      ws.cell(r, 1).number(item.id);
      ws.cell(r, 2).string(item.noi_dung || "");
      ws.cell(r, 3).string(item.nhan_cam_xuc || "");
      ws.cell(r, 4).number(item.danh_gia_sao || 3);
      ws.cell(r, 5).string(tuDienHaiLong[item.danh_gia_sao] || "Bình thường");
      ws.cell(r, 6).number(parseFloat(item.do_tin_cay) || 0);
      ws.cell(r, 7).string(item.ly_do_ai_cham || "");
    });

    wb.write("BaoCao_SentiFlow.xlsx", res);
  } catch (error) {
    return res.status(500).json({ success: false });
  }
};
