class DiemThoiGian {
  final String thoiGian;
  final int tichCuc;
  final int tieuCuc;
  final int trungLap;

  DiemThoiGian({
    required this.thoiGian,
    required this.tichCuc,
    required this.tieuCuc,
    required this.trungLap,
  });

  factory DiemThoiGian.fromJson(Map<String, dynamic> json) {
    return DiemThoiGian(
      thoiGian:
          json['thoi_gian']?.toString() ?? json['mox']?.toString() ?? '00/00',
      tichCuc: int.tryParse(json['tich_cuc']?.toString() ?? '0') ?? 0,
      tieuCuc: int.tryParse(json['tieu_cuc']?.toString() ?? '0') ?? 0,
      trungLap: int.tryParse(json['trung_lap']?.toString() ?? '0') ?? 0,
    );
  }
}
