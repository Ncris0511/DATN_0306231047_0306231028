const db = require("../config/db");

exports.register = async (req, res) => {
  try {
    const { ho_ten, email, so_dien_thoai, mat_khau, device_id } = req.body;

    const checkUser = await db.TaiKhoan.findOne({ where: { email: email } });
    if (checkUser) return res.status(400).json({ success: false, message: "Email đã tồn tại!" });

    if (device_id) {
      const guestUser = await db.TaiKhoan.findOne({ where: { device_id: device_id, vai_tro: "khach" } });
      if (guestUser) {
        guestUser.ho_ten = ho_ten || "Thành viên SentiFlow";
        guestUser.email = email;
        guestUser.so_dien_thoai = so_dien_thoai;
        guestUser.mat_khau = mat_khau;
        guestUser.vai_tro = "nguoi_dung";
        await guestUser.save();
        return res.status(201).json({ success: true, data: guestUser });
      }
    }

    const newUser = await db.TaiKhoan.create({
      ho_ten: ho_ten || "Thành viên SentiFlow", email: email, so_dien_thoai: so_dien_thoai, 
      mat_khau: mat_khau, device_id: device_id, vai_tro: "nguoi_dung"
    });
    return res.status(201).json({ success: true, data: newUser });
  } catch (error) { return res.status(500).json({ success: false, message: "Lỗi Server" }); }
};

exports.login = async (req, res) => {
  try {
    const { email, mat_khau, device_id } = req.body;
    const user = await db.TaiKhoan.findOne({ where: { email: email, mat_khau: mat_khau } });

    if (!user) return res.status(400).json({ success: false, message: "Sai tài khoản hoặc mật khẩu" });

    if (device_id) {
      const guestUser = await db.TaiKhoan.findOne({ where: { device_id: device_id, vai_tro: "khach" } });
      if (guestUser && guestUser.id !== user.id) {
        await db.ChuDePhanTich.update({ id_tai_khoan: user.id }, { where: { id_tai_khoan: guestUser.id } });
        await guestUser.destroy(); 
      }
    }
    return res.status(200).json({ success: true, data: user });
  } catch (error) { return res.status(500).json({ success: false, message: "Lỗi Server" }); }
};

exports.guest = async (req, res) => {
  try {
    const { device_id } = req.body;
    let user = await db.TaiKhoan.findOne({ where: { device_id: device_id } });
    if (!user) { user = await db.TaiKhoan.create({ device_id: device_id, ho_ten: "Khách Ẩn Danh", vai_tro: "khach" }); }
    return res.status(200).json({ success: true, data: user });
  } catch (error) { return res.status(500).json({ success: false, message: "Lỗi Server" }); }
};

exports.doiMatKhau = async (req, res) => {
  try {
    const { id_tai_khoan, mat_khau_cu, mat_khau_moi } = req.body;
    const user = await db.TaiKhoan.findByPk(id_tai_khoan);
    if (!user || user.mat_khau !== mat_khau_cu) return res.status(400).json({ success: false, message: "Sai mật khẩu cũ" });
    user.mat_khau = mat_khau_moi; await user.save();
    return res.status(200).json({ success: true });
  } catch (error) { return res.status(500).json({ success: false }); }
};

exports.capNhatThongTin = async (req, res) => {
  try {
    const { id_tai_khoan, ho_ten } = req.body;
    const user = await db.TaiKhoan.findByPk(id_tai_khoan);
    if (!user) return res.status(404).json({ success: false });
    user.ho_ten = ho_ten; await user.save();
    return res.status(200).json({ success: true });
  } catch (error) { return res.status(500).json({ success: false }); }
};