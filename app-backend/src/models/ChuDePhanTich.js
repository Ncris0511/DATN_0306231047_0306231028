const { DataTypes } = require("sequelize");

module.exports = (sequelize) => {
  const ChuDePhanTich = sequelize.define(
    "ChuDePhanTich",
    {
      id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
      id_tai_khoan: { type: DataTypes.INTEGER, allowNull: false },
      ten_chu_de: { type: DataTypes.STRING(255), allowNull: false },
      phan_quyet_ai: {
        type: DataTypes.ENUM(
          "APPROVED_NEN_MUA",
          "CAUTION_CAN_NHAC",
          "CHUA_HOI_CHAN",
        ),
        defaultValue: "CHUA_HOI_CHAN",
      },
      tom_tat_ai: { type: DataTypes.TEXT, allowNull: true },
      ngay_tao: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    },
    {
      tableName: "chu_de_phan_tich",
      timestamps: false,
    },
  );
  return ChuDePhanTich;
};
