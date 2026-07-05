class KhiaCanh {
  final String tenKhiaCanh;
  final String nhanCamXuc;
  KhiaCanh({required this.tenKhiaCanh, required this.nhanCamXuc});
  factory KhiaCanh.fromJson(Map<String, dynamic> json) {
    return KhiaCanh(
      tenKhiaCanh: json['ten_khia_canh']?.toString() ?? 'Chung',
      nhanCamXuc: json['nhan_cam_xuc']?.toString() ?? 'TRUNG_LAP',
    );
  }
}

class KetQuaAI {
  final int id;
  final String noiDung;
  final String nhanCamXuc;
  final double doTinCay;
  final String lyDoCuaAI;
  final String tieuChiTinCay;
  final int danhGiaSao;
  final String lyDoDanhGiaSao; // BẾN CHỨA MỚI
  final List<KhiaCanh> danhSachKhiaCanh;

  KetQuaAI({
    required this.id,
    required this.noiDung,
    required this.nhanCamXuc,
    required this.doTinCay,
    required this.lyDoCuaAI,
    required this.tieuChiTinCay,
    this.danhGiaSao = 3,
    this.lyDoDanhGiaSao = '',
    this.danhSachKhiaCanh = const [],
  });

  factory KetQuaAI.fromJson(Map<String, dynamic> json) {
    var khiaCanhRaw = json['danhSachKhiaCanh'] ?? json['danh_sach_khia_canh'];
    List<KhiaCanh> listKC = [];
    if (khiaCanhRaw is List)
      listKC = khiaCanhRaw.map((e) => KhiaCanh.fromJson(e)).toList();

    return KetQuaAI(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      noiDung:
          json['noi_dung']?.toString() ?? json['noiDung']?.toString() ?? '',
      nhanCamXuc:
          json['nhan_cam_xuc']?.toString() ??
          json['nhanCamXuc']?.toString() ??
          'TRUNG_LAP',
      doTinCay: double.tryParse(json['do_tin_cay']?.toString() ?? '0.0') ?? 0.0,
      lyDoCuaAI:
          json['ly_do_ai_cham']?.toString() ??
          json['ly_do_cua_ai']?.toString() ??
          '',
      tieuChiTinCay: json['tieu_chi_tin_cay']?.toString() ?? '',
      danhGiaSao: int.tryParse(json['danh_gia_sao']?.toString() ?? '3') ?? 3,
      lyDoDanhGiaSao:
          json['ly_do_danh_gia_sao']?.toString() ?? '', // NHẬN DỮ LIỆU Ở ĐÂY
      danhSachKhiaCanh: listKC,
    );
  }
}
