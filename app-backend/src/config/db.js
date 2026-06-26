const { Sequelize, DataTypes } = require("sequelize");
require("dotenv").config();

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: "mysql",
    logging: false,
    timezone: "+07:00",
  },
);

const db = {};
db.Sequelize = Sequelize;
db.sequelize = sequelize;

// Nạp Model
db.TaiKhoan = require("../models/TaiKhoan")(sequelize);
db.ChuDePhanTich = require("../models/ChuDePhanTich")(sequelize);
db.BinhLuan = require("../models/BinhLuan")(sequelize);
db.ChiTietKhiaCanh = require("../models/ChiTietKhiaCanh")(sequelize);

// Ràng buộc Khóa ngoại (Associations)
db.TaiKhoan.hasMany(db.ChuDePhanTich, {
  foreignKey: "id_tai_khoan",
  as: "danhSachChuDe",
});
db.ChuDePhanTich.belongsTo(db.TaiKhoan, {
  foreignKey: "id_tai_khoan",
  as: "taiKhoan",
});

db.ChuDePhanTich.hasMany(db.BinhLuan, {
  foreignKey: "id_chu_de",
  as: "danhSachBinhLuan",
});
db.BinhLuan.belongsTo(db.ChuDePhanTich, {
  foreignKey: "id_chu_de",
  as: "chuDe",
});

db.BinhLuan.hasMany(db.ChiTietKhiaCanh, {
  foreignKey: "id_binh_luan",
  as: "danhSachKhiaCanh",
});
db.ChiTietKhiaCanh.belongsTo(db.BinhLuan, {
  foreignKey: "id_binh_luan",
  as: "binhLuan",
});

sequelize
  .authenticate()
  .then(() => console.log("✅ Đã kết nối MySQL thành công!"))
  .catch((err) => console.error("❌ Lỗi kết nối DB:", err));

module.exports = db;
