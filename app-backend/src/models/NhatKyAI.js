module.exports = (sequelize, DataTypes) => {
  return sequelize.define(
    "NhatKyAI",
    {
      id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      id_binh_luan: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      thoi_gian_phan_hoi_ms: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      trang_thai_api: {
        type: DataTypes.ENUM("THANH_CONG", "THAT_BAI"),
        defaultValue: "THANH_CONG",
      },
      thong_bao_loi: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      ngay_tao: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
      },
    },
    { tableName: "nhat_ky_ai", timestamps: false },
  );
};
