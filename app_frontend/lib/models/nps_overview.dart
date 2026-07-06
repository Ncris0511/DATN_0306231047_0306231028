class ChiSoNps {
  final int tongSo;
  final int tichCuc;
  final int tieuCuc;
  final int trungLap;
  final int diemNps;

  ChiSoNps({
    required this.tongSo,
    required this.tichCuc,
    required this.tieuCuc,
    required this.trungLap,
    required this.diemNps,
  });

  factory ChiSoNps.fromJson(Map<String, dynamic> json) {
    return ChiSoNps(
      tongSo: int.tryParse(json['tong_so']?.toString() ?? '0') ?? 0,
      tichCuc: int.tryParse(json['tich_cuc']?.toString() ?? '0') ?? 0,
      tieuCuc: int.tryParse(json['tieu_cuc']?.toString() ?? '0') ?? 0,
      trungLap: int.tryParse(json['trung_lap']?.toString() ?? '0') ?? 0,
      diemNps: int.tryParse(json['diem_nps']?.toString() ?? '0') ?? 0,
    );
  }
}
