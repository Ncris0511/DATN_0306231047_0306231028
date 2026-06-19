const { toDefaultValue } = require("sequelize/lib/utils");

module.exports = (sequelize, DataTypes) => {
  return sequelize.define(
    "TaiKhoan",
    {
      id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      ten_dang_nhap: {
        type: DataTypes.STRING(50),
        allowNull: false,
        unique: true,
      },
      mat_khau: {
        type: DataTypes.STRING(255),
        allowNull: false,
      },
      vai_tro: {
        type: DataTypes.ENUM("nguoi_dung", "quan_tri"),
        defaultValue: "Nguoi_dung",
      },
      ngay_tao: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
      },
    },
    { tableName: "tai_khoan", timestamps: false },
  );
};
