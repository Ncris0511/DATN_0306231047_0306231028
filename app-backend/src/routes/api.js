const express = require("express");
const router = express.Router();

// Gọi các file điều khiển (Controllers)
const aiController = require("../controllers/aiController");
const thongKeController = require("../controllers/thongKeController");
const adminController = require("../controllers/adminController");

// API USER
router.post("/binh-luan/phan-tich", aiController.phanTichBinhLuan);

// ĐÂY LÀ CHỖ VỪA ĐƯỢC SỬA LẠI TÊN CHO ĐÚNG:
router.get("/binh-luan/thong-ke", thongKeController.layDashboard);

// API ADMIN

router.post("/admin/login", adminController.loginAdmin);
router.get("/admin/thong-ke-thoi-gian", adminController.thongKeThoiGian);
router.get("/admin/binh-luan-danh-sach", adminController.layDanhSachBinhLuan);
router.get("/admin/xuat-bao-cao", adminController.xuatBaoCao);

module.exports = router;
