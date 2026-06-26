const { DataTypes } = require("sequelize");

module.exports = (sequelize) => {
  const BinhLuan = sequelize.define(
    "BinhLuan",
    {
      id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
      id_chu_de: { type: DataTypes.INTEGER, allowNull: false },
      noi_dung: { type: DataTypes.TEXT, allowNull: false },
      hinh_anh_dinh_kem: { type: DataTypes.STRING(255), allowNull: true },

      nhan_cam_xuc: {
        type: DataTypes.ENUM("TICH_CUC", "TIEU_CUC", "CHUA_PHAN_LOAI"),
        defaultValue: "CHUA_PHAN_LOAI",
      },
      danh_gia_sao: { type: DataTypes.TINYINT, allowNull: true },
      do_tin_cay: { type: DataTypes.DECIMAL(5, 4), allowNull: true },

      tieu_chi_tin_cay: { type: DataTypes.TEXT, allowNull: true },
      sua_loi_chinh_ta: { type: DataTypes.TEXT, allowNull: true },
      ly_do_ai_cham: { type: DataTypes.TEXT, allowNull: true },

      thoi_gian_xu_ly_ms: { type: DataTypes.INTEGER, allowNull: true },
      ai_version: {
        type: DataTypes.STRING(50),
        defaultValue: "gemini-2.5-flash",
      },

      ngay_tao: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    },
    {
      tableName: "binh_luan",
      timestamps: false,
    },
  );
  return BinhLuan;
};
