class ChuDeModel {
  final int id;
  final int idTaiKhoan;
  final String tenChuDe;
  String phanQuyetAi;
  String? tomTatAi;
  final int soLuongBinhLuan;

  ChuDeModel({
    required this.id,
    required this.idTaiKhoan,
    required this.tenChuDe,
    required this.phanQuyetAi,
    this.tomTatAi,
    this.soLuongBinhLuan = 0,
  });

  factory ChuDeModel.fromJson(Map<String, dynamic> json) {
    return ChuDeModel(
      id: json['id'] ?? 0,
      idTaiKhoan: json['id_tai_khoan'] ?? 0,
      tenChuDe: json['ten_chu_de'] ?? 'Khong ten',
      phanQuyetAi: json['phan_quyet_ai'] ?? 'CHUA_HOI_CHAN',
      tomTatAi: json['tom_tat_ai'],
      soLuongBinhLuan: json['so_luong_binh_luan'] ?? 0,
    );
  }
}
