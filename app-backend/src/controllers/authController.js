const db = require("../config/db");

// 1. GUEST ONBOARDING (Khách dùng thử)
exports.loginGuest = async (req, res) => {
  try {
    const { device_id } = req.body;
    if (!device_id) {
      return res
        .status(400)
        .json({
          success: false,
          message: "Thiếu định danh thiết bị (device_id)!",
        });
    }

    const [user, created] = await db.TaiKhoan.findOrCreate({
      where: { device_id: device_id },
      defaults: { ho_ten: "Khách Ẩn Danh", vai_tro: "khach" },
    });

    return res.status(200).json({
      success: true,
      is_new_guest: created,
      message: created
        ? "Khởi tạo phiên Khách thành công!"
        : "Đã khôi phục dữ liệu Khách cũ!",
      data: user,
    });
  } catch (error) {
    return res
      .status(500)
      .json({ success: false, message: "Lỗi định danh thiết bị máy chủ" });
  }
};

// 2. ĐĂNG KÝ TÀI KHOẢN CHÍNH THỨC (Có đồng hóa tài khoản bóng)
exports.registerUser = async (req, res) => {
  try {
    const { ten_dang_nhap, mat_khau, ho_ten, device_id } = req.body;
    if (!ten_dang_nhap || !mat_khau) {
      return res
        .status(400)
        .json({
          success: false,
          message: "Vui lòng nhập đủ tài khoản và mật khẩu!",
        });
    }

    const daTonTai = await db.TaiKhoan.findOne({ where: { ten_dang_nhap } });
    if (daTonTai) {
      return res
        .status(409)
        .json({
          success: false,
          message: "Tên đăng nhập này đã có người sử dụng!",
        });
    }

    // Nếu khách đang xài thử bấm nâng cấp -> Cập nhật thẳng vào bản ghi cũ
    if (device_id) {
      const khachBong = await db.TaiKhoan.findOne({
        where: { device_id, vai_tro: "khach" },
      });
      if (khachBong) {
        khachBong.ten_dang_nhap = ten_dang_nhap;
        khachBong.mat_khau = mat_khau;
        khachBong.ho_ten = ho_ten || "Thành viên SentiFlow";
        khachBong.vai_tro = "nguoi_dung";
        await khachBong.save();

        return res
          .status(200)
          .json({
            success: true,
            message: "Nâng cấp tài khoản thành công!",
            data: khachBong,
          });
      }
    }

    const userMoi = await db.TaiKhoan.create({
      ten_dang_nhap,
      mat_khau,
      ho_ten: ho_ten || "Thành viên SentiFlow",
      vai_tro: "nguoi_dung",
    });

    return res
      .status(201)
      .json({ success: true, message: "Đăng ký thành công!", data: userMoi });
  } catch (error) {
    return res
      .status(500)
      .json({ success: false, message: "Lỗi máy chủ khi đăng ký" });
  }
};

// 3. ĐĂNG NHẬP NGƯỜI DÙNG THẬT
exports.loginUser = async (req, res) => {
  try {
    const { ten_dang_nhap, mat_khau } = req.body;
    const user = await db.TaiKhoan.findOne({
      where: { ten_dang_nhap, mat_khau, vai_tro: "nguoi_dung" },
    });

    if (!user) {
      return res
        .status(401)
        .json({ success: false, message: "Sai tên đăng nhập hoặc mật khẩu!" });
    }

    return res
      .status(200)
      .json({ success: true, message: "Đăng nhập thành công!", data: user });
  } catch (error) {
    return res
      .status(500)
      .json({ success: false, message: "Lỗi máy chủ đăng nhập" });
  }
};
// 4. THAY ĐỔI MẬT KHẨU (Change Password)
exports.doiMatKhau = async (req, res) => {
  try {
    const { id_tai_khoan, mat_khau_cu, mat_khau_moi } = req.body;

    if (!id_tai_khoan || !mat_khau_cu || !mat_khau_moi) {
      return res
        .status(400)
        .json({
          success: false,
          message: "Vui lòng điền đầy đủ mật khẩu cũ và mới!",
        });
    }

    const user = await db.TaiKhoan.findByPk(id_tai_khoan);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "Tài khoản không tồn tại!" });
    }

    // Chặn trường hợp tài khoản Khách vãng lai chưa có pass mà đòi đi đổi
    if (user.vai_tro === "khach" || !user.mat_khau) {
      return res
        .status(403)
        .json({
          success: false,
          message: "Tài khoản Khách dùng thử không có mật khẩu để đổi!",
        });
    }

    // Kiểm tra mật khẩu cũ có khớp DB không
    if (user.mat_khau !== mat_khau_cu) {
      return res
        .status(401)
        .json({ success: false, message: "Mật khẩu cũ không chính xác!" });
    }

    if (mat_khau_cu === mat_khau_moi) {
      return res
        .status(400)
        .json({
          success: false,
          message: "Mật khẩu mới không được trùng với mật khẩu hiện tại!",
        });
    }

    user.mat_khau = mat_khau_moi;
    await user.save();

    return res
      .status(200)
      .json({ success: true, message: "Thay đổi mật khẩu thành công!" });
  } catch (error) {
    console.error("❌ Lỗi đổi mật khẩu:", error);
    return res
      .status(500)
      .json({ success: false, message: "Lỗi máy chủ khi cập nhật mật khẩu" });
  }
};

// 5. CẬP NHẬT THÔNG TIN CÁ NHÂN (Họ tên)
exports.capNhatThongTin = async (req, res) => {
  try {
    const { id_tai_khoan, ho_ten } = req.body;
    if (!id_tai_khoan || !ho_ten) {
      return res
        .status(400)
        .json({
          success: false,
          message: "Thiếu ID tài khoản hoặc họ tên mới!",
        });
    }

    const user = await db.TaiKhoan.findByPk(id_tai_khoan);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy người dùng!" });
    }

    user.ho_ten = ho_ten.trim();
    await user.save();

    return res.status(200).json({
      success: true,
      message: "Cập nhật hồ sơ thành công!",
      data: { id: user.id, ho_ten: user.ho_ten, vai_tro: user.vai_tro },
    });
  } catch (error) {
    return res
      .status(500)
      .json({ success: false, message: "Lỗi máy chủ cập nhật hồ sơ" });
  }
};
