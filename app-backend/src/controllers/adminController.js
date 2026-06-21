// Gọi cấu hình database và các model bảng dữ liệu để tương tác với MySQL
const db = require("../config/db");

// Gọi toán tử Op của Sequelize để dùng cho các câu lệnh điều kiện phức tạp (như so sánh ngày tháng)
const { Op } = require("sequelize");

const xl = require("excel4node");

// =========================================================================
// FUNCTION 1 (ĐÃ NÂNG CẤP): LẤY DANH SÁCH CÓ HỖ TRỢ BỘ LỌC TỪ FLUTTER
// =========================================================================
exports.layDanhSachBinhLuan = async (req, res) => {
  try {
    // Hứng 3 biến bộ lọc từ App gửi lên (nếu có)
    const { nhan_cam_xuc, sao, tim_kiem } = req.query;
    const dieuKienWhere = {};

    // 1. Nếu Flutter gửi: ?nhan_cam_xuc=TICH_CUC
    if (
      nhan_cam_xuc &&
      ["TICH_CUC", "TIEU_CUC", "CHUA_PHAN_LOAI"].includes(
        nhan_cam_xuc.toUpperCase(),
      )
    ) {
      dieuKienWhere.nhan_cam_xuc = nhan_cam_xuc.toUpperCase();
    }

    // 2. Nếu Flutter gửi: ?sao=5
    if (sao && !isNaN(sao)) {
      dieuKienWhere.danh_gia_sao = parseInt(sao);
    }

    // 3. Nếu Flutter gửi ô tìm kiếm: ?tim_kiem=màn hình
    if (tim_kiem && tim_kiem.trim() !== "") {
      dieuKienWhere.noi_dung = { [Op.like]: `%${tim_kiem.trim()}%` };
    }

    const danhSach = await db.BinhLuan.findAll({
      where: dieuKienWhere,
      order: [["ngay_tao", "DESC"]],
    });

    return res.status(200).json({
      success: true,
      tong_so_loc_duoc: danhSach.length,
      data: danhSach,
    });
  } catch (error) {
    console.error("❌ Lỗi lấy danh sách Admin:", error);
    return res
      .status(500)
      .json({ success: false, message: "Lỗi tải danh sách!" });
  }
};

// =========================================================================
// FUNCTION 2 (ĐÃ NÂNG CẤP): THỐNG KÊ BIỂU ĐỒ LINH HOẠT THEO THỜI GIAN
// =========================================================================
exports.thongKeTheoThoiGian = async (req, res) => {
  try {
    const { loc_theo } = req.query; // Hứng biến từ Flutter: '7_ngay', '30_ngay', 'thang_nay', 'nam_nay'
    let mocBatDau = new Date();
    mocBatDau.setHours(0, 0, 0, 0); // Đưa về 00:00:00 của ngày được chọn

    if (loc_theo === "30_ngay") {
      mocBatDau.setDate(mocBatDau.getDate() - 30);
    } else if (loc_theo === "thang_nay") {
      mocBatDau = new Date(mocBatDau.getFullYear(), mocBatDau.getMonth(), 1); // Mùng 1 tháng này
    } else if (loc_theo === "nam_nay") {
      mocBatDau = new Date(mocBatDau.getFullYear(), 0, 1); // Mùng 1 tháng 1 đầu năm
    } else {
      mocBatDau.setDate(mocBatDau.getDate() - 7); // Mặc định là 7 ngày
    }

    const thongKe = await db.BinhLuan.findAll({
      attributes: [
        [db.sequelize.fn("DATE", db.sequelize.col("ngay_tao")), "ngay"],
        [db.sequelize.fn("COUNT", db.sequelize.col("id")), "tong_so"],
        [
          db.sequelize.fn(
            "SUM",
            db.sequelize.literal(
              "CASE WHEN nhan_cam_xuc = 'TICH_CUC' THEN 1 ELSE 0 END",
            ),
          ),
          "tich_cuc",
        ],
        [
          db.sequelize.fn(
            "SUM",
            db.sequelize.literal(
              "CASE WHEN nhan_cam_xuc = 'TIEU_CUC' THEN 1 ELSE 0 END",
            ),
          ),
          "tieu_cuc",
        ],
      ],
      where: { ngay_tao: { [Op.gte]: mocBatDau } },
      group: [db.sequelize.fn("DATE", db.sequelize.col("ngay_tao"))],
      order: [[db.sequelize.fn("DATE", db.sequelize.col("ngay_tao")), "ASC"]],
    });

    return res.status(200).json({
      success: true,
      khung_thoi_gian: loc_theo || "7_ngay",
      data: thongKe,
    });
  } catch (error) {
    console.error("❌ Lỗi thống kê thời gian:", error);
    return res
      .status(500)
      .json({ success: false, message: "Lỗi truy vấn thời gian" });
  }
};

// =========================================================================
// FUNCTION 3 (ĐÃ NÂNG CẤP LÊN ĐỈNH CAO): XUẤT FILE EXCEL (.XLSX) CÓ TÔ MÀU
// =========================================================================
exports.xuatBaoCaoCSV = async (req, res) => {
  // Vẫn giữ tên hàm cũ để file routes/api.js không bị lỗi
  try {
    const tatCa = await db.BinhLuan.findAll({ order: [["ngay_tao", "DESC"]] });

    // 1. Khởi tạo một Workbook (File Excel)
    const wb = new xl.Workbook();
    const ws = wb.addWorksheet("Báo cáo Cảm xúc AI");

    // 2. Định nghĩa các "Cọ sơn" (Styles)
    const styleTieuDe = wb.createStyle({
      font: { bold: true, color: "#FFFFFF", size: 12 },
      fill: { type: "pattern", patternType: "solid", fgColor: "#1F4E78" }, // Xanh Navy bệ vệ
      alignment: { horizontal: "center", vertical: "center" },
    });

    const styleXanhKhen = wb.createStyle({
      font: { color: "#27AE60", bold: true },
    }); // Xanh lá
    const styleDoChe = wb.createStyle({
      font: { color: "#C0392B", bold: true },
    }); // Đỏ gắt
    const styleBinhThuong = wb.createStyle({ font: { color: "#333333" } });

    // 3. Vẽ dòng Tiêu đề cột
    const headers = [
      "ID",
      "Nội dung bình luận",
      "AI Nhận diện",
      "Số Sao",
      "Đánh giá",
      "Độ tin cậy AI",
      "Lý do AI chấm",
      "Ngày bình luận",
    ];
    headers.forEach((text, index) => {
      ws.cell(1, index + 1)
        .string(text)
        .style(styleTieuDe);
    });
    ws.row(1).setHeight(28); // Kéo lề tiêu đề cao lên cho thoáng

    // 4. Đổ dữ liệu và Tô màu từng ô
    tatCa.forEach((item, rowIdx) => {
      const row = rowIdx + 2; // Bắt đầu từ dòng số 2

      ws.cell(row, 1)
        .number(item.id)
        .style({ alignment: { horizontal: "center" } });
      ws.cell(row, 2).string(item.noi_dung || "");

      // Chọn cọ sơn theo cảm xúc
      let coSonCamXuc = styleBinhThuong;
      if (item.nhan_cam_xuc === "TICH_CUC") coSonCamXuc = styleXanhKhen;
      if (item.nhan_cam_xuc === "TIEU_CUC") coSonCamXuc = styleDoChe;

      ws.cell(row, 3)
        .string(item.nhan_cam_xuc)
        .style(coSonCamXuc)
        .style({ alignment: { horizontal: "center" } });
      ws.cell(row, 4)
        .number(item.danh_gia_sao || 3)
        .style({ alignment: { horizontal: "center" } });
      ws.cell(row, 5).string(item.muc_do_hai_long || "");

      // Ép định dạng phần trăm (Ví dụ: 0.965 -> hiển thị Excel là 96.50%)
      ws.cell(row, 6)
        .number(parseFloat(item.do_tin_cay || 0))
        .style({ numberFormat: "0.00%" });

      // Xử lý an toàn cột lý do mới thêm
      const lyDoGhiNhan =
        item.dataValues.ly_do_ai_cham || "Hệ thống tự nhận diện";
      ws.cell(row, 7).string(lyDoGhiNhan);

      ws.cell(row, 8).string(new Date(item.ngay_tao).toLocaleString("vi-VN"));
    });

    // 5. Căn chỉnh độ rộng cột tự động cho đẹp
    ws.column(2).setWidth(45); // Cột nội dung cho rộng nhất
    ws.column(3).setWidth(16);
    ws.column(6).setWidth(15);
    ws.column(7).setWidth(35); // Cột lý do cho rộng thứ nhì
    ws.column(8).setWidth(20);

    // 6. Gửi thẳng file Excel xịn về trình duyệt / điện thoại
    wb.write("BaoCao_SentiFlow.xlsx", res);
  } catch (error) {
    console.error("❌ Lỗi xuất Excel:", error);
    return res
      .status(500)
      .json({ success: false, message: "Lỗi tạo file Excel" });
  }
};
