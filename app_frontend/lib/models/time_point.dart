class DiemThoiGian {
  final String mox;
  final int tichCuc;
  final int tieuCuc;

  DiemThoiGian({required this.mox, required this.tichCuc, required this.tieuCuc});

  factory DiemThoiGian.fromJson(Map<String, dynamic> json) {
    return DiemThoiGian(
      mox: json['mox']?.toString() ?? '',
      tichCuc: (json['tich_cuc'] as num?)?.toInt() ?? 0,
      tieuCuc: (json['tieu_cuc'] as num?)?.toInt() ?? 0,
    );
  }
}