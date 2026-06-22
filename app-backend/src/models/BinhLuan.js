const { DataTypes } = require("sequelize");

module.exports = (sequelize) => {
  const BinhLuan = sequelize.define(
    "BinhLuan",
    {
      id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
      id_tai_khoan: { type: DataTypes.INTEGER, allowNull: true },
      noi_dung: { type: DataTypes.TEXT, allowNull: false },
      nhan_cam_xuc: {
        type: DataTypes.ENUM("TICH_CUC", "TIEU_CUC", "CHUA_PHAN_LOAI"),
        defaultValue: "CHUA_PHAN_LOAI",
      },
      danh_gia_sao: { type: DataTypes.TINYINT, allowNull: true },
      muc_do_hai_long: { type: DataTypes.STRING(50), allowNull: true },
      do_tin_cay: { type: DataTypes.DECIMAL(5, 4), allowNull: true },
      ly_do_ai_cham: { type: DataTypes.TEXT, allowNull: true },
      ai_version: {
        type: DataTypes.STRING(50),
        defaultValue: "gemini-2.5-flash",
      },

      ngay_tao: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    },
    { tableName: "binh_luan", timestamps: false },
  );

  return BinhLuan;
};
