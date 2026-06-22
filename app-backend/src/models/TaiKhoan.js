const { DataTypes } = require("sequelize");

module.exports = (sequelize) => {
  const TaiKhoan = sequelize.define(
    "TaiKhoan",
    {
      id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
      ten_dang_nhap: {
        type: DataTypes.STRING(50),
        allowNull: false,
        unique: true,
      },
      mat_khau: { type: DataTypes.STRING(255), allowNull: false },
      ho_ten: { type: DataTypes.STRING(100), allowNull: false }, // Đã khai báo ho_ten
      vai_tro: {
        type: DataTypes.ENUM("nguoi_dung", "quan_tri"),
        defaultValue: "nguoi_dung",
      },
      ngay_tao: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    },
    { tableName: "tai_khoan", timestamps: false },
  );

  return TaiKhoan;
};
