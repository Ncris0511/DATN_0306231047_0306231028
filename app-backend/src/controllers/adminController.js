const db = require("../config/db");
const xl = require("excel4node");

// 1. ĐĂNG NHẬP ADMIN


// Các hàm khác giữ nguyên, chỉ sửa hàm loginAdmin
exports.loginAdmin = async (req, res) => {
  try {
    const { email, mat_khau } = req.body;
    // Admin cũng đăng nhập bằng email
    const admin = await db.TaiKhoan.findOne({
      where: { email: email, mat_khau: mat_khau, vai_tro: "quan_tri" },
    });

    if (!admin) {
      return res.status(400).json({ success: false, message: "Tài khoản không tồn tại hoặc không có quyền" });
    }

    return res.status(200).json({ success: true, data: admin });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Lỗi Server" });
  }
};
// GIỮ NGUYÊN CÁC HÀM XUẤT BÁO CÁO, THỐNG KÊ Ở DƯỚI...

// 2. THỐNG KÊ BIỂU ĐỒ THỜI GIAN ĐỘNG
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

// 3. LẤY DANH SÁCH BÌNH LUẬN THÔ
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

// 4. KẾT XUẤT BÁO CÁO GIÁM ĐỊNH MẸ-CON (Đã ghim Độ tin cậy tổng thể lên đỉnh)
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

      // TÍNH TOÁN ĐỘ TIN CẬY TRUNG BÌNH CỦA SẢN PHẨM
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

      // VẼ BANNER GHIM ĐỘ TIN CẬY Ở TRỂN
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

// 5. THỐNG KÊ CHUYÊN SÂU THEO SẢN PHẨM CHO DASHBOARD
exports.thongKeTheoSanPham = async (req, res) => {
  try {
    const sql = `
      SELECT c.id AS id_chu_de, c.ten_chu_de, c.phan_quyet_ai, c.tom_tat_ai,
        COUNT(b.id) AS tong_binh_luan, ROUND(AVG(b.danh_gia_sao), 1) AS sao_trung_binh,
        SUM(CASE WHEN b.nhan_cam_xuc = 'TICH_CUC' THEN 1 ELSE 0 END) AS tich_cuc,
        SUM(CASE WHEN b.nhan_cam_xuc = 'TIEU_CUC' THEN 1 ELSE 0 END) AS tieu_cuc,
        SUM(CASE WHEN b.nhan_cam_xuc = 'CHUA_PHAN_LOAI' THEN 1 ELSE 0 END) AS trung_lap
      FROM chu_de_phan_tich c LEFT JOIN binh_luan b ON c.id = b.id_chu_de
      GROUP BY c.id, c.ten_chu_de, c.phan_quyet_ai, c.tom_tat_ai ORDER BY tong_binh_luan DESC;
    `;
    const [rows] = await db.sequelize.query(sql);

    const dataSanPham = rows.map((sp) => {
      const tong = parseInt(sp.tong_binh_luan) || 0;
      const khen = parseInt(sp.tich_cuc) || 0;
      return {
        id_chu_de: sp.id_chu_de,
        ten_san_pham: sp.ten_chu_de,
        phan_quyet_chot_ha: sp.phan_quyet_ai,
        tom_tat_ai: sp.tom_tat_ai || "Chưa có nhận định",
        tong_binh_luan: tong,
        diem_sao_tb: parseFloat(sp.sao_trung_binh) || 0,
        chi_tiet_cam_xuc: {
          tich_cuc: khen,
          tieu_cuc: parseInt(sp.tieu_cuc) || 0,
          trung_lap: parseInt(sp.trung_lap) || 0,
        },
        ty_le_hai_long: tong > 0 ? `${Math.round((khen / tong) * 100)}%` : "0%",
      };
    });
    return res
      .status(200)
      .json({
        success: true,
        tong_so_san_pham: dataSanPham.length,
        data: dataSanPham,
      });
  } catch (error) {
    return res.status(500).json({ success: false });
  }
};
