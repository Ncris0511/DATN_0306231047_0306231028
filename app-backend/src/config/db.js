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

//Nạp Model
db.Taikhoan = require("../models/TaiKhoan")(sequelize, DataTypes);
db.BinhLuan = require("../models/BinhLuan")(sequelize, DataTypes);
db.NhatKyAI = require("../models/NhatKyAI")(sequelize, DataTypes);
//Tạo mối quan hệ khóa ngoại
db.Taikhoan.hasMany(db.BinhLuan, { foreignKey: "id_tai_khoan" });
db.BinhLuan.belongsTo(db.Taikhoan, { foreignKey: "id_tai_khoan" });
db.BinhLuan.hasOne(db.NhatKyAI, { foreignKey: "id_binh_luan" });
db.NhatKyAI.belongsTo(db.BinhLuan, { foreignKey: "id_binh_luan" });

sequelize
  .authenticate()
  .then(() => console.log("✅ Đã kết nối MySQL thành công!"))
  .catch((err) => console.error("❌ Lỗi:", err));

module.exports = db;
