const express = require("express");
const router = express.Router();

const aiController = require("../controllers/aiController");
const thongKeController = require("../controllers/thongKeController");
const adminController = require("../controllers/adminController");
const authController = require("../controllers/authController");
const phienController = require("../controllers/phienController");

// Cổng Định danh (Đã sửa tên hàm cho khớp với authController.js)
router.post("/auth/guest", authController.guest);
router.post("/auth/register", authController.register);
router.post("/auth/login", authController.login);
router.put("/auth/doi-mat-khau", authController.doiMatKhau);
router.put("/auth/cap-nhat-thong-tin", authController.capNhatThongTin);

// Cổng Quản lý Sidebar
router.post("/sidebar/tao-moi", phienController.taoChuDeMoi);
router.get("/sidebar/danh-sach", phienController.layDanhSachSidebar);
router.get("/sidebar/chi-tiet/:id", phienController.layChiTietPhienChat);
router.delete("/sidebar/xoa/:id", phienController.xoaTopic);
router.post("/sidebar/hoi-chan/:id", phienController.hoiChanAI);

// Cổng AI & Thống kê App
router.post("/binh-luan/phan-tich", aiController.phanTichBinhLuan);
router.get("/binh-luan/thong-ke", thongKeController.layDashboard);

// Cổng Quản trị viên
router.post("/admin/login", adminController.loginAdmin);
router.get("/admin/thong-ke-thoi-gian", adminController.thongKeThoiGian);
router.get("/admin/chi-so-nps", adminController.layChiSoNps);
router.get("/admin/binh-luan-danh-sach", adminController.layDanhSachBinhLuan);
router.get("/admin/xuat-bao-cao", adminController.xuatBaoCao);
router.get("/admin/thong-ke-san-pham", adminController.thongKeTheoSanPham);

module.exports = router;