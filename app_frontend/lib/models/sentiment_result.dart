class KetQuaAI {
  final int id;
  final int idTaiKhoan;
  final String noiDung;
  final String nhanCamXuc;
  final int danhGiaSao;
  final String mucDoHaiLong;
  final double doTinCay;
  final String lyDoCuaAI;
  final int thoiGianMs;
  final String aiVersion;
  final String ngayTaoStr;

  KetQuaAI({
    required this.id,
    required this.idTaiKhoan,
    required this.noiDung,
    required this.nhanCamXuc,
    required this.danhGiaSao,
    required this.mucDoHaiLong,
    required this.doTinCay,
    required this.lyDoCuaAI,
    required this.thoiGianMs,
    required this.aiVersion,
    required this.ngayTaoStr,
  });

  factory KetQuaAI.fromJson(Map<String, dynamic> json) {
    int parseIntSafe(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double parseDoubleSafe(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return KetQuaAI(
      id: parseIntSafe(json['id']),
      idTaiKhoan: parseIntSafe(json['id_tai_khoan'] ?? json['idTaiKhoan']),
      noiDung: json['noi_dung']?.toString() ?? json['noiDung']?.toString() ?? 'Nội dung trống',
      nhanCamXuc: json['nhan_cam_xuc']?.toString() ?? json['nhanCamXuc']?.toString() ?? 'TRUNG_LAP',
      danhGiaSao: parseIntSafe(json['danh_gia_sao'] ?? json['danhGiaSao'] ?? 3),
      mucDoHaiLong: json['muc_do_hai_long']?.toString() ?? 'Bình thường',
      doTinCay: parseDoubleSafe(json['do_tin_cay'] ?? json['doTinCay']),
      lyDoCuaAI: json['ly_do_ai_cham']?.toString() ?? json['ly_do_ai']?.toString() ?? 'AI tự động phân loại',
      thoiGianMs: parseIntSafe(json['thoi_gian_xu_ly_ms'] ?? json['thoiGianMs']),
      aiVersion: json['ai_version']?.toString() ?? json['aiVersion']?.toString() ?? 'gemini-2.5-flash',
      ngayTaoStr: json['ngay_tao']?.toString() ?? '',
    );
  }
}