const db = require("../config/db");
const xl = require("excel4node");

// 1. ĐĂNG NHẬP ADMIN
exports.loginAdmin = async (req, res) => {
  try {
    const { ten_dang_nhap, mat_khau } = req.body;

    if (!ten_dang_nhap || !mat_khau) {
      return res
        .status(400)
        .json({
          success: false,
          message: "Vui lòng nhập tài khoản và mật khẩu!",
        });
    }

    const [users] = await db.sequelize.query(
      `SELECT id, ten_dang_nhap, ho_ten, vai_tro FROM tai_khoan 
             WHERE ten_dang_nhap = :ten_dang_nhap AND mat_khau = :mat_khau AND vai_tro = 'quan_tri' LIMIT 1`,
      { replacements: { ten_dang_nhap, mat_khau } },
    );

    if (users.length === 0) {
      return res
        .status(401)
        .json({
          success: false,
          message: "Tài khoản hoặc mật khẩu Admin không đúng!",
        });
    }

    const admin = users[0];
    return res.status(200).json({
      success: true,
      message: "Đăng nhập Quản trị viên thành công!",
      data: {
        id: admin.id,
        ten_dang_nhap: admin.ten_dang_nhap,
        ho_ten: admin.ho_ten, // Lấy đúng "Trần Quản Trị" từ DB
        vai_tro: admin.vai_tro,
      },
    });
  } catch (error) {
    console.error("❌ Lỗi Login Admin:", error);
    return res
      .status(500)
      .json({ success: false, message: "Lỗi xác thực máy chủ" });
  }
};

// 2. THỐNG KÊ THỜI GIAN LINH HOẠT (Bypass 100% ONLY_FULL_GROUP_BY bằng JS Mapping)
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

    let sql = "";

    // Tầng 1: SQL thuần gom số liệu thô chuẩn Strict Mode
    if (boLoc === "hom_nay") {
      sql = `
                SELECT 
                    HOUR(ngay_tao) AS raw_unit,
                    COUNT(*) AS tong_so,
                    SUM(CASE WHEN nhan_cam_xuc = 'TICH_CUC' THEN 1 ELSE 0 END) AS tich_cuc,
                    SUM(CASE WHEN nhan_cam_xuc = 'TIEU_CUC' THEN 1 ELSE 0 END) AS tieu_cuc
                FROM binh_luan
                WHERE DATE(ngay_tao) = DATE(NOW())
                GROUP BY HOUR(ngay_tao)
                ORDER BY HOUR(ngay_tao) ASC;
            `;
    } else if (boLoc === "7_ngay") {
      sql = `
                SELECT 
                    DATE_FORMAT(ngay_tao, '%Y-%m-%d') AS raw_unit,
                    COUNT(*) AS tong_so,
                    SUM(CASE WHEN nhan_cam_xuc = 'TICH_CUC' THEN 1 ELSE 0 END) AS tich_cuc,
                    SUM(CASE WHEN nhan_cam_xuc = 'TIEU_CUC' THEN 1 ELSE 0 END) AS tieu_cuc
                FROM binh_luan
                WHERE ngay_tao >= DATE_SUB(DATE(NOW()), INTERVAL 7 DAY)
                GROUP BY DATE_FORMAT(ngay_tao, '%Y-%m-%d')
                ORDER BY DATE_FORMAT(ngay_tao, '%Y-%m-%d') ASC;
            `;
    } else if (boLoc === "thang_nay") {
      sql = `
                SELECT 
                    DATE_FORMAT(ngay_tao, '%Y-%m-%d') AS raw_unit,
                    COUNT(*) AS tong_so,
                    SUM(CASE WHEN nhan_cam_xuc = 'TICH_CUC' THEN 1 ELSE 0 END) AS tich_cuc,
                    SUM(CASE WHEN nhan_cam_xuc = 'TIEU_CUC' THEN 1 ELSE 0 END) AS tieu_cuc
                FROM binh_luan
                WHERE YEAR(ngay_tao) = YEAR(NOW()) AND MONTH(ngay_tao) = MONTH(NOW())
                GROUP BY DATE_FORMAT(ngay_tao, '%Y-%m-%d')
                ORDER BY DATE_FORMAT(ngay_tao, '%Y-%m-%d') ASC;
            `;
    } else if (boLoc === "nam_nay") {
      sql = `
                SELECT 
                    MONTH(ngay_tao) AS raw_unit,
                    COUNT(*) AS tong_so,
                    SUM(CASE WHEN nhan_cam_xuc = 'TICH_CUC' THEN 1 ELSE 0 END) AS tich_cuc,
                    SUM(CASE WHEN nhan_cam_xuc = 'TIEU_CUC' THEN 1 ELSE 0 END) AS tieu_cuc
                FROM binh_luan
                WHERE YEAR(ngay_tao) = YEAR(NOW())
                GROUP BY MONTH(ngay_tao)
                ORDER BY MONTH(ngay_tao) ASC;
            `;
    } else if (boLoc === "tat_ca") {
      sql = `
                SELECT 
                    DATE_FORMAT(ngay_tao, '%Y-%m') AS raw_unit,
                    COUNT(*) AS tong_so,
                    SUM(CASE WHEN nhan_cam_xuc = 'TICH_CUC' THEN 1 ELSE 0 END) AS tich_cuc,
                    SUM(CASE WHEN nhan_cam_xuc = 'TIEU_CUC' THEN 1 ELSE 0 END) AS tieu_cuc
                FROM binh_luan
                GROUP BY DATE_FORMAT(ngay_tao, '%Y-%m')
                ORDER BY DATE_FORMAT(ngay_tao, '%Y-%m') ASC;
            `;
    }

    const [rows] = await db.sequelize.query(sql);

    // Tầng 2: Node.js xử lý "trang điểm" nhãn mox cho Flutter vẽ biểu đồ fl_chart
    const cleanData = rows.map((item) => {
      let moxLabel = "";
      if (boLoc === "hom_nay") {
        moxLabel = String(item.raw_unit).padStart(2, "0") + ":00";
      } else if (boLoc === "7_ngay" || boLoc === "thang_nay") {
        const parts = item.raw_unit.split("-");
        moxLabel = `${parts[2]}/${parts[1]}`;
      } else if (boLoc === "nam_nay") {
        moxLabel = `Tháng ${item.raw_unit}`;
      } else if (boLoc === "tat_ca") {
        const parts = item.raw_unit.split("-");
        moxLabel = `${parts[1]}/${parts[0]}`;
      }

      return {
        mox: moxLabel,
        tong_so: parseInt(item.tong_so) || 0,
        tich_cuc: parseInt(item.tich_cuc) || 0,
        tieu_cuc: parseInt(item.tieu_cuc) || 0,
      };
    });

    return res
      .status(200)
      .json({ success: true, khung_thoi_gian: boLoc, data: cleanData });
  } catch (error) {
    console.error("❌ Lỗi Thống kê linh hoạt:", error);
    return res
      .status(500)
      .json({ success: false, message: "Lỗi máy chủ kết xuất biểu đồ" });
  }
};

// 3. LỌC DANH SÁCH BÌNH LUẬN CHO ADMIN
exports.layDanhSachBinhLuan = async (req, res) => {
  try {
    const { nhan_cam_xuc, tim_kiem } = req.query;
    let querySql = `SELECT * FROM binh_luan WHERE 1=1`;
    let replacements = {};

    if (nhan_cam_xuc) {
      querySql += ` AND nhan_cam_xuc = :nhan_cam_xuc`;
      replacements.nhan_cam_xuc = nhan_cam_xuc;
    }
    if (tim_kiem) {
      querySql += ` AND noi_dung LIKE :tim_kiem`;
      replacements.tim_kiem = `%${tim_kiem}%`;
    }
    querySql += ` ORDER BY ngay_tao DESC`;

    const [rows] = await db.sequelize.query(querySql, { replacements });
    return res
      .status(200)
      .json({ success: true, tong_so_loc_duoc: rows.length, data: rows });
  } catch (e) {
    return res
      .status(500)
      .json({ success: false, message: "Lỗi lấy danh sách" });
  }
};

// 4. KẾT XUẤT BÁO CÁO EXCEL (.xlsx) - IN NGUYÊN VĂN LÝ DO AI CHẤM
exports.xuatBaoCao = async (req, res) => {
  try {
    const [rows] = await db.sequelize.query(
      `SELECT * FROM binh_luan ORDER BY ngay_tao DESC`,
    );

    const wb = new xl.Workbook();
    const ws = wb.addWorksheet("Báo cáo Cảm xúc AI");

    const headerStyle = wb.createStyle({
      font: { color: "#FFFFFF", bold: true, size: 12 },
      fill: {
        type: "pattern",
        patternType: "solid",
        bgColor: "#1B365D",
        fgColor: "#1B365D",
      },
      alignment: { horizontal: "center", vertical: "center" },
    });

    const styleTichCuc = wb.createStyle({
      font: { color: "#2E7D32", bold: true },
    });
    const styleTieuCuc = wb.createStyle({
      font: { color: "#C62828", bold: true },
    });
    const styleTrungLap = wb.createStyle({
      font: { color: "#EF6C00", bold: true },
    });
    const styleNormal = wb.createStyle({ font: { size: 11 } });

    const headers = [
      "ID",
      "Nội dung bình luận",
      "AI Nhận diện",
      "Số Sao",
      "Mức độ hài lòng",
      "Độ tin cậy AI",
      "Lý do AI chấm",
      "Ngày bình luận",
    ];
    headers.forEach((h, idx) =>
      ws
        .cell(1, idx + 1)
        .string(h)
        .style(headerStyle),
    );
    ws.row(1).setHeight(30);

    rows.forEach((item, index) => {
      const r = index + 2;
      ws.cell(r, 1).number(item.id).style(styleNormal);
      ws.cell(r, 2)
        .string(item.noi_dung || "")
        .style(styleNormal);

      let cellNhan = ws.cell(r, 3).string(item.nhan_cam_xuc || "");
      if (item.nhan_cam_xuc === "TICH_CUC") cellNhan.style(styleTichCuc);
      else if (item.nhan_cam_xuc === "TIEU_CUC") cellNhan.style(styleTieuCuc);
      else cellNhan.style(styleTrungLap);

      ws.cell(r, 4)
        .number(item.danh_gia_sao || 3)
        .style(styleNormal);
      ws.cell(r, 5)
        .string(item.muc_do_hai_long || "")
        .style(styleNormal);
      ws.cell(r, 6)
        .number(parseFloat(item.do_tin_cay) || 0)
        .style(styleNormal);

      // In nguyên văn lập luận XAI từ DB ra Excel:
      ws.cell(r, 7)
        .string(item.ly_do_ai_cham || "Hệ thống tự động ghi nhận")
        .style(styleNormal);

      const d = new Date(item.ngay_tao);
      const dateStr = `${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}:${String(d.getSeconds()).padStart(2, "0")} ${String(d.getDate()).padStart(2, "0")}/${String(d.getMonth() + 1).padStart(2, "0")}/${d.getFullYear()}`;
      ws.cell(r, 8).string(dateStr).style(styleNormal);
    });

    ws.column(2).setWidth(45);
    ws.column(7).setWidth(55); // Mở rộng cột Lý do lên 55 để hiển thị văn bản dài
    ws.column(8).setWidth(22);

    wb.write("BaoCao_SentiFlow.xlsx", res);
  } catch (error) {
    console.error("❌ Lỗi xuất Excel:", error);
    return res
      .status(500)
      .json({ success: false, message: "Lỗi kết xuất Excel" });
  }
};
