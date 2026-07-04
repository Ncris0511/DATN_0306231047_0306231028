class KetQuaAI {
  final int id;
  final String noiDung;
  final String nhanCamXuc;
  final double doTinCay;
  final String lyDoCuaAI;
  final String tieuChiTinCay;

  KetQuaAI({
    required this.id,
    required this.noiDung,
    required this.nhanCamXuc,
    required this.doTinCay,
    required this.lyDoCuaAI,
    required this.tieuChiTinCay,
  });

  factory KetQuaAI.fromJson(Map<String, dynamic> json) {
    return KetQuaAI(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      noiDung:
          json['noi_dung']?.toString() ??
          json['noiDung']?.toString() ??
          '',
      nhanCamXuc:
          json['nhan_cam_xuc']?.toString() ??
          json['nhanCamXuc']?.toString() ??
          'TRUNG_LAP',
      doTinCay:
          (json['do_tin_cay'] as num?)?.toDouble() ?? 0.0,
      lyDoCuaAI:
          json['ly_do_cua_ai']?.toString() ?? '',
      tieuChiTinCay:
          json['tieu_chi_tin_cay']?.toString() ?? '',
    );
  }
}