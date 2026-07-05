const { DataTypes } = require("sequelize");

module.exports = (sequelize) => {
  const TaiKhoan = sequelize.define(
    "TaiKhoan",
    {
      id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
      device_id: { type: DataTypes.STRING(255), allowNull: true, unique: true },
      ten_dang_nhap: { type: DataTypes.STRING(100), allowNull: true, unique: true },
      mat_khau: { type: DataTypes.STRING(255), allowNull: true },
      ho_ten: { type: DataTypes.STRING(100), defaultValue: "Khách Ẩn Danh" },
      
      
      email: { type: DataTypes.STRING(255), allowNull: true },
      so_dien_thoai: { type: DataTypes.STRING(20), allowNull: true },

      vai_tro: { type: DataTypes.ENUM("khach", "nguoi_dung", "quan_tri"), defaultValue: "khach" },
      ngay_tao: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    },
    {
      tableName: "tai_khoan",
      timestamps: false,
    },
  );
  return TaiKhoan;
};