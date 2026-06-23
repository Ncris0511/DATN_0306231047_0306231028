class DiemThoiGian {
  final String mox;
  final int tongSo;
  final int tichCuc;
  final int tieuCuc;

  DiemThoiGian({
    required this.mox,
    required this.tongSo,
    required this.tichCuc,
    required this.tieuCuc,
  });

  factory DiemThoiGian.fromJson(Map<String, dynamic> json) {
    return DiemThoiGian(
      mox: json['mox']?.toString() ?? '',
      tongSo: (json['tong_so'] as num?)?.toInt() ?? 0,
      tichCuc: (json['tich_cuc'] as num?)?.toInt() ?? 0,
      tieuCuc: (json['tieu_cuc'] as num?)?.toInt() ?? 0,
    );
  }
}
