const { DataTypes } = require("sequelize");

module.exports = (sequelize) => {
  const ChiTietKhiaCanh = sequelize.define(
    "ChiTietKhiaCanh",
    {
      id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
      id_binh_luan: { type: DataTypes.INTEGER, allowNull: false },
      ten_khia_canh: { type: DataTypes.STRING(100), allowNull: false },
      nhan_cam_xuc: {
        type: DataTypes.ENUM("TICH_CUC", "TIEU_CUC", "TRUNG_LAP"),
        allowNull: false,
      },
      trich_dan_goc: { type: DataTypes.TEXT, allowNull: true },
    },
    {
      tableName: "chi_tiet_khia_canh",
      timestamps: false,
    },
  );
  return ChiTietKhiaCanh;
};
