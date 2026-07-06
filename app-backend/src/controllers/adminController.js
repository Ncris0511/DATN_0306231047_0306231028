const db = require("../config/db");
const xl = require("excel4node");
const { QueryTypes } = require("sequelize"); // THÊM THƯ VIỆN ÉP KIỂU DỮ LIỆU SẠCH

// HÀM HỖ TRỢ LỌC THỜI GIAN
const getWhereClause = (loc_theo, prefix = "") => {
  const col = prefix ? `${prefix}.ngay_tao` : "ngay_tao";
  if (loc_theo === "hom_nay") return `DATE(${col}) = CURDATE()`;
  if (loc_theo === "7_ngay")
    return `${col} >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)`;
  if (loc_theo === "thang_nay")
    return `MONTH(${col}) = MONTH(CURDATE()) AND YEAR(${col}) = YEAR(CURDATE())`;
  if (loc_theo === "nam_nay") return `YEAR(${col}) = YEAR(CURDATE())`;
  return `1=1`; // tat_ca
};

exports.loginAdmin = async (req, res) => {
  try {
    const { email, mat_khau } = req.body;
    const admin = await db.TaiKhoan.findOne({
      where: { email: email, mat_khau: mat_khau, vai_tro: "quan_tri" },
    });
    if (!admin)
      return res
        .status(400)
        .json({ success: false, message: "Tài khoản không tồn tại" });
    return res.status(200).json({ success: true, data: admin });
  } catch (error) {
    return res.status(500).json({ success: false });
  }
};

exports.layChiSoNps = async (req, res) => {
  try {
    const loc_theo = req.query.loc_theo || "7_ngay";
    const whereClause = getWhereClause(loc_theo);

    // Dùng QueryTypes.SELECT và COALESCE để ép dữ liệu trả về số sạch 100%
    const rows = await db.sequelize.query(
      `
      SELECT 
        COUNT(*) AS tong_so,
        COALESCE(SUM(CASE WHEN nhan_cam_xuc = 'TICH_CUC' THEN 1 ELSE 0 END), 0) AS tich_cuc,
        COALESCE(SUM(CASE WHEN nhan_cam_xuc = 'TIEU_CUC' THEN 1 ELSE 0 END), 0) AS tieu_cuc,
        COALESCE(SUM(CASE WHEN nhan_cam_xuc = 'CHUA_PHAN_LOAI' THEN 1 ELSE 0 END), 0) AS trung_lap,
        COALESCE(SUM(CASE WHEN danh_gia_sao = 5 THEN 1 ELSE 0 END), 0) AS promoters,
        COALESCE(SUM(CASE WHEN danh_gia_sao IN (1,2) THEN 1 ELSE 0 END), 0) AS detractors
      FROM binh_luan WHERE ${whereClause}
    `,
      { type: QueryTypes.SELECT },
    );

    const data = rows[0] || {};
    const tongSo = Number(data.tong_so) || 0;
    const promoters = Number(data.promoters) || 0;
    const detractors = Number(data.detractors) || 0;
    const diemNps =
      tongSo > 0 ? Math.round(((promoters - detractors) / tongSo) * 100) : 0;

    return res.status(200).json({
      success: true,
      data: {
        tong_so: tongSo,
        tich_cuc: Number(data.tich_cuc) || 0,
        tieu_cuc: Number(data.tieu_cuc) || 0,
        trung_lap: Number(data.trung_lap) || 0,
        diem_nps: diemNps,
      },
    });
  } catch (error) {
    console.error("Lỗi layChiSoNps:", error);
    return res.status(500).json({ success: false });
  }
};

exports.thongKeThoiGian = async (req, res) => {
  try {
    const loc_theo = req.query.loc_theo || "7_ngay";
    const whereClause = getWhereClause(loc_theo);

    // ========================================================
    // ĐỘNG THÁI GOM NHÓM THỜI GIAN THEO ĐÚNG Ý ĐẠI TƯỚNG
    // ========================================================
    let groupBy = `DATE_FORMAT(ngay_tao, '%d/%m')`; // Mặc định

    if (loc_theo === "hom_nay") {
      groupBy = `DATE_FORMAT(ngay_tao, '%H:00')`; // Gom theo Giờ
    } else if (loc_theo === "7_ngay") {
      groupBy = `DATE_FORMAT(ngay_tao, '%d/%m')`; // Gom theo Ngày
    } else if (loc_theo === "thang_nay") {
      groupBy = `CONCAT('Tuần ', WEEK(ngay_tao, 1))`; // Gom theo Tuần
    } else if (loc_theo === "nam_nay") {
      groupBy = `DATE_FORMAT(ngay_tao, 'Thg %m')`; // Gom theo Tháng
    } else if (loc_theo === "tat_ca") {
      groupBy = `DATE_FORMAT(ngay_tao, 'Năm %Y')`; // Gom theo Năm
    }

    const rows = await db.sequelize.query(
      `
      SELECT ${groupBy} AS thoi_gian,
        COALESCE(SUM(CASE WHEN nhan_cam_xuc = 'TICH_CUC' THEN 1 ELSE 0 END), 0) as tich_cuc,
        COALESCE(SUM(CASE WHEN nhan_cam_xuc = 'TIEU_CUC' THEN 1 ELSE 0 END), 0) as tieu_cuc,
        COALESCE(SUM(CASE WHEN nhan_cam_xuc = 'CHUA_PHAN_LOAI' THEN 1 ELSE 0 END), 0) as trung_lap
      FROM binh_luan WHERE ${whereClause} 
      GROUP BY ${groupBy} 
      ORDER BY MIN(ngay_tao) ASC LIMIT 30
    `,
      { type: QueryTypes.SELECT },
    );

    return res.status(200).json({ success: true, data: rows });
  } catch (error) {
    console.error("Lỗi thongKeThoiGian:", error);
    return res.status(500).json({ success: false, data: [] });
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

exports.thongKeTheoSanPham = async (req, res) => {
  try {
    const loc_theo = req.query.loc_theo || "7_ngay";
    const whereClause = getWhereClause(loc_theo, "b");

    const rows = await db.sequelize.query(
      `
      SELECT c.id AS id_chu_de, c.id_tai_khoan, c.ten_chu_de, c.phan_quyet_ai, c.tom_tat_ai, COUNT(b.id) AS so_luong_binh_luan
      FROM chu_de_phan_tich c LEFT JOIN binh_luan b ON c.id = b.id_chu_de AND ${whereClause}
      GROUP BY c.id, c.id_tai_khoan, c.ten_chu_de, c.phan_quyet_ai, c.tom_tat_ai ORDER BY so_luong_binh_luan DESC;
    `,
      { type: QueryTypes.SELECT },
    );

    return res.status(200).json({ success: true, data: rows });
  } catch (error) {
    return res.status(500).json({ success: false });
  }
};

exports.xuatBaoCao = async (req, res) => {
  try {
    const [topics] = await db.sequelize.query(
      `SELECT * FROM chu_de_phan_tich ORDER BY id DESC`,
    );
    const [comments] = await db.sequelize.query(
      `SELECT * FROM binh_luan ORDER BY ngay_tao ASC`,
    );
    const wb = new xl.Workbook();
    const ws = wb.addWorksheet("Phán quyết Mua sắm AI");

    const titleStyle = wb.createStyle({
      font: { color: "#FFFFFF", bold: true, size: 14 },
      fill: {
        type: "pattern",
        patternType: "solid",
        bgColor: "#1B365D",
        fgColor: "#1B365D",
      },
      alignment: { horizontal: "center", vertical: "center" },
    });
    const spApproved = wb.createStyle({
      font: { color: "#FFFFFF", bold: true, size: 11 },
      fill: {
        type: "pattern",
        patternType: "solid",
        bgColor: "#2E7D32",
        fgColor: "#2E7D32",
      },
      alignment: { vertical: "center" },
    });
    const spCaution = wb.createStyle({
      font: { color: "#FFFFFF", bold: true, size: 11 },
      fill: {
        type: "pattern",
        patternType: "solid",
        bgColor: "#C62828",
        fgColor: "#C62828",
      },
      alignment: { vertical: "center" },
    });
    const spNeutral = wb.createStyle({
      font: { color: "#FFFFFF", bold: true, size: 11 },
      fill: {
        type: "pattern",
        patternType: "solid",
        bgColor: "#455A64",
        fgColor: "#455A64",
      },
      alignment: { vertical: "center" },
    });
    const spAdviceStyle = wb.createStyle({
      font: { italic: true, color: "#1B365D", bold: true, size: 11 },
      fill: {
        type: "pattern",
        patternType: "solid",
        bgColor: "#FFF9C4",
        fgColor: "#FFF9C4",
      },
      alignment: { vertical: "center" },
    });
    const tblHeader = wb.createStyle({
      font: { color: "#222222", bold: true, size: 10 },
      fill: {
        type: "pattern",
        patternType: "solid",
        bgColor: "#CFD8DC",
        fgColor: "#CFD8DC",
      },
      border: { bottom: { style: "medium", color: "#78909C" } },
      alignment: { horizontal: "center", vertical: "center" },
    });
    const thinEdge = { style: "thin", color: "#E0E0E0" };
    const borderCfg = {
      left: thinEdge,
      right: thinEdge,
      top: thinEdge,
      bottom: thinEdge,
    };
    const styleNormal = wb.createStyle({
      font: { size: 11 },
      border: borderCfg,
      alignment: { wrapText: true, vertical: "center" },
    });
    const styleCenter = wb.createStyle({
      font: { size: 11 },
      border: borderCfg,
      alignment: { horizontal: "center", vertical: "center" },
    });
    const badgeKhen = wb.createStyle({
      font: { color: "#1B5E20", bold: true },
      fill: {
        type: "pattern",
        patternType: "solid",
        bgColor: "#C8E6C9",
        fgColor: "#C8E6C9",
      },
      border: borderCfg,
      alignment: { horizontal: "center", vertical: "center" },
    });
    const badgeChe = wb.createStyle({
      font: { color: "#B71C1C", bold: true },
      fill: {
        type: "pattern",
        patternType: "solid",
        bgColor: "#FFcdd2",
        fgColor: "#FFcdd2",
      },
      border: borderCfg,
      alignment: { horizontal: "center", vertical: "center" },
    });
    const badgeTrung = wb.createStyle({
      font: { color: "#E65100", bold: true },
      fill: {
        type: "pattern",
        patternType: "solid",
        bgColor: "#FFE0B2",
        fgColor: "#FFE0B2",
      },
      border: borderCfg,
      alignment: { horizontal: "center", vertical: "center" },
    });

    ws.cell(1, 1, 2, 7, true)
      .string(
        "BÁO CÁO THẨM ĐỊNH CẢM XÚC & PHÁN QUYẾT MUA SẮM SẢN PHẨM (SENTIFLOW AI)",
      )
      .style(titleStyle);
    let currRow = 4;
    const tuDienHaiLong = {
      5: "Rất hài lòng",
      4: "Hài lòng",
      3: "Bình thường",
      2: "Thất vọng",
      1: "Rất thất vọng",
    };

    topics.forEach((topic) => {
      const spComments = comments.filter((c) => c.id_chu_de === topic.id);
      let avgTinCay = "0.0";
      if (spComments.length > 0) {
        const tongTC = spComments.reduce(
          (sum, c) => sum + (parseFloat(c.do_tin_cay) || 0),
          0,
        );
        avgTinCay = ((tongTC / spComments.length) * 100).toFixed(1);
      }

      let bannerStyle = spNeutral;
      let textVerdict = "CHƯA HỘI CHẨN";
      if (topic.phan_quyet_ai === "APPROVED_NEN_MUA") {
        bannerStyle = spApproved;
        textVerdict = "✔ NÊN MUA (APPROVED)";
      } else if (topic.phan_quyet_ai === "CAUTION_CAN_NHAC") {
        bannerStyle = spCaution;
        textVerdict = "⚠ CÂN NHẮC / CẢNH BÁO (CAUTION)";
      }

      ws.row(currRow).setHeight(28);
      ws.cell(currRow, 1, currRow, 7, true)
        .string(
          `  📦 SẢN PHẨM: ${topic.ten_chu_de.toUpperCase()}    |    PHÁN QUYẾT AI: ${textVerdict}    |    🛡️ ĐỘ TIN CẬY TB: ${avgTinCay}%`,
        )
        .style(bannerStyle);
      currRow++;

      ws.row(currRow).setHeight(24);
      ws.cell(currRow, 1, currRow, 7, true)
        .string(
          `   💡 Lời khuyên chốt hạ: "${topic.tom_tat_ai || "Chưa bấm nút hội chẩn tổng hợp"}"`,
        )
        .style(spAdviceStyle);
      currRow++;

      ws.row(currRow).setHeight(22);
      const subHeaders = [
        "STT",
        "Nội dung phản hồi của khách hàng",
        "AI Nhận diện",
        "Số Sao",
        "Độ tin cậy",
        "Giải trình ngữ nghĩa từ AI",
        "Thời gian",
      ];
      subHeaders.forEach((h, idx) =>
        ws
          .cell(currRow, idx + 1)
          .string(h)
          .style(tblHeader),
      );
      currRow++;

      if (spComments.length === 0) {
        ws.row(currRow).setHeight(24);
        ws.cell(currRow, 1, currRow, 7, true)
          .string("Chưa có bình luận nào cho sản phẩm này.")
          .style(styleCenter);
        currRow++;
      } else {
        spComments.forEach((cmt, cmtIdx) => {
          ws.row(currRow).setHeight(28);
          ws.cell(currRow, 1)
            .number(cmtIdx + 1)
            .style(styleCenter);
          ws.cell(currRow, 2)
            .string(cmt.noi_dung || "")
            .style(styleNormal);

          let sBadge = badgeTrung;
          if (cmt.nhan_cam_xuc === "TICH_CUC") sBadge = badgeKhen;
          else if (cmt.nhan_cam_xuc === "TIEU_CUC") sBadge = badgeChe;
          ws.cell(currRow, 3)
            .string(cmt.nhan_cam_xuc || "TRUNG_LAP")
            .style(sBadge);

          const sao = cmt.danh_gia_sao || 3;
          ws.cell(currRow, 4)
            .string(`${sao}★ (${tuDienHaiLong[sao]})`)
            .style(styleCenter);
          ws.cell(currRow, 5)
            .string(`${((parseFloat(cmt.do_tin_cay) || 0) * 100).toFixed(1)}%`)
            .style(styleCenter);
          ws.cell(currRow, 6)
            .string(cmt.ly_do_ai_cham || "")
            .style(styleNormal);

          const d = new Date(cmt.ngay_tao);
          const dStr = `${String(d.getDate()).padStart(2, "0")}/${String(d.getMonth() + 1).padStart(2, "0")}/${d.getFullYear()} ${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
          ws.cell(currRow, 7).string(dStr).style(styleCenter);
          currRow++;
        });
      }
      currRow += 2;
    });

    ws.column(1).setWidth(6);
    ws.column(2).setWidth(42);
    ws.column(3).setWidth(16);
    ws.column(4).setWidth(18);
    ws.column(5).setWidth(14);
    ws.column(6).setWidth(45);
    ws.column(7).setWidth(16);
    wb.write("BaoCao_ChotHa_SentiFlow.xlsx", res);
  } catch (error) {
    return res
      .status(500)
      .json({ success: false, message: "Lỗi kết xuất Excel" });
  }
};
