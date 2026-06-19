// Gọi cấu hình database và các model bảng dữ liệu để tương tác với MySQL
const db = require('../config/db');

// Gọi toán tử Op của Sequelize để dùng cho các câu lệnh điều kiện phức tạp (như so sánh ngày tháng)
const { Op } = require('sequelize');

// =========================================================================
// FUNCTION 1: LẤY DANH SÁCH BÌNH LUẬN (Đáp ứng yêu cầu: Quản lý danh sách bình luận)
// =========================================================================
exports.layDanhSachBinhLuan = async (req, res) => {
    try {
        // Lấy toàn bộ danh sách bình luận từ database, sắp xếp câu mới nhất lên đầu tiên
        const danhSach = await db.BinhLuan.findAll({
            order: [['ngay_tao', 'DESC']] // DESC nghĩa là giảm dần (mới nhất lên trước)
        });

        // Trả dữ liệu mảng về cho Flutter hiển thị lên màn hình danh sách của Admin
        return res.status(200).json({
            success: true,
            message: 'Tải danh sách bình luận thành công!',
            data: danhSach
        });
    } catch (error) {
        console.error("❌ Lỗi lấy danh sách bình luận:", error);
        return res.status(500).json({ success: false, message: 'Lỗi máy chủ không thể lấy danh sách!' });
    }
};

// =========================================================================
// FUNCTION 2: THỐNG KÊ THEO THỜI GIAN (Đáp ứng yêu cầu: Thống kê theo thời gian ngày, tuần, tháng)
// Lấy số lượng Tích cực / Tiêu cực / Trung lập được gom nhóm theo từng ngày trong 7 ngày gần nhất
// =========================================================================
exports.thongKeTheoThoiGian = async (req, res) => {
    try {
        // Tính mốc thời gian 7 ngày trước kể từ thời điểm hiện tại
        const bayNgayTruoc = new Date();
        bayNgayTruoc.setDate(bayNgayTruoc.getDate() - 7);

        // Truy vấn nâng cao: Gom nhóm dữ liệu theo ngày để làm nguyên liệu vẽ biểu đồ đường (Line Chart)
        const thongKeNgay = await db.BinhLuan.findAll({
            attributes: [
                // Hàm cắt lấy phần Ngày tháng năm (bỏ phần giờ phút giây) của MySQL và đặt tên đại diện là 'ngay'
                [db.sequelize.fn('DATE', db.sequelize.col('ngay_tao')), 'ngay'],
                // Hàm đếm tổng số bình luận của ngày đó và đặt tên đại diện là 'tong_so'
                [db.sequelize.fn('COUNT', db.sequelize.col('id')), 'tong_so'],
                // Đếm xem trong ngày đó có bao nhiêu câu TICH_CUC
                [db.sequelize.fn('SUM', db.sequelize.literal("CASE WHEN nhan_cam_xuc = 'TICH_CUC' THEN 1 ELSE 0 END")), 'tich_cuc'],
                // Đếm xem trong ngày đó có bao nhiêu câu TIEU_CUC
                [db.sequelize.fn('SUM', db.sequelize.literal("CASE WHEN nhan_cam_xuc = 'TIEU_CUC' THEN 1 ELSE 0 END")), 'tieu_cuc'],
                // Đếm xem trong ngày đó có bao nhiêu câu TRUNG_LAP
                [db.sequelize.fn('SUM', db.sequelize.literal("CASE WHEN nhan_cam_xuc = 'CHUA_PHAN_LOAI' THEN 1 ELSE 0 END")), 'trung_lap']
            ],
            where: {
                // Điều kiện lọc: Chỉ lấy dữ liệu từ mốc 7 ngày trước đến nay
                ngay_tao: { [Op.gte]: bayNgayTruoc }
            },
            group: [db.sequelize.fn('DATE', db.sequelize.col('ngay_tao'))], // Gom nhóm theo ngày
            order: [[db.sequelize.fn('DATE', db.sequelize.col('ngay_tao')), 'ASC']] // Sắp xếp từ ngày cũ đến ngày mới để vẽ biểu đồ từ trái qua phải
        });

        return res.status(200).json({
            success: true,
            message: 'Lấy dữ liệu thống kê theo thời gian thành công!',
            data: thongKeNgay
        });
    } catch (error) {
        console.error("❌ Lỗi thống kê theo thời gian:", error);
        return res.status(500).json({ success: false, message: 'Lỗi server không thể tổng hợp báo cáo ngày!' });
    }
};

// =========================================================================
// FUNCTION 3: XUẤT DỮ LIỆU BÁO CÁO CSV (Đáp ứng yêu cầu: Xuất dữ liệu báo cáo)
// Hệ thống sẽ tự động tổng hợp MySQL thành một chuỗi dữ liệu CSV chuẩn để Admin tải về mở thẳng bằng Excel
// =========================================================================
exports.xuatBaoCaoCSV = async (req, res) => {
    try {
        // Lấy tất cả bình luận trong database ra để xuất file
        const tatCaBinhLuan = await db.BinhLuan.findAll({ order: [['ngay_tao', 'DESC']] });

        // Tạo phần tiêu đề cột cho file Excel (phân cách nhau bằng dấu phẩy)
        let csvContent = "Mã ID,Nội dung bình luận,Nhãn cảm xúc,Độ tin cậy,Ngày tạo\n";

        // Vòng lặp duyệt qua từng dòng dữ liệu để nối chuỗi thành các hàng trong file
        tatCaBinhLuan.forEach((item) => {
            // Xử lý chuỗi nội dung bình luận: Xóa các dấu xuống dòng lỡ có để tránh làm lệch hàng Excel
            const noiDungSach = item.noi_dung.replace(/\n/g, " ").replace(/,/g, " ");
            
            // Định dạng tỷ lệ phần trăm hiển thị
            const doTinCayPhanTram = item.do_tin_cay ? `${(item.do_tin_cay * 100).toFixed(2)}%` : '0%';

            // Nối dòng dữ liệu vào chuỗi tổng
            csvContent += `${item.id},${noiDungSach},${item.nhan_cam_xuc},${doTinCayPhanTram},${item.ngay_tao}\n`;
        });

        // THIẾT LẬP CẤU HÌNH ĐẶC BIỆT ĐỂ DOWNLOAD FILE QUA EXPRSS
        // 1. Thêm mã hiệu BOM (Byte Order Mark) của UTF-8 để khi Excel mở lên không bị lỗi font chữ Tiếng Việt có dấu
        const bom = Buffer.from('\uFEFF', 'utf-8');
        const fileBuffer = Buffer.concat([bom, Buffer.from(csvContent, 'utf-8')]);

        // 2. Cấu hình Header ép trình duyệt hoặc điện thoại phải tải xuống thành file tên là 'BaoCao_CamXuc_AI.csv'
        res.setHeader('Content-Type', 'text/csv; charset=utf-8');
        res.setHeader('Content-Disposition', 'attachment; filename=BaoCao_CamXuc_AI.csv');

        // Gửi file về cho người dùng tải xuống
        return res.status(200).send(fileBuffer);

    } catch (error) {
        console.error("❌ Lỗi xuất báo cáo dữ liệu:", error);
        return res.status(500).json({ success: false, message: 'Gặp sự cố khi kết xuất file báo cáo!' });
    }
};