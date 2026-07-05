class ChiSoNps {
  final int tichCuc;
  final int tieuCuc;
  final int trungLap;
  final int diemNps;

  ChiSoNps({
    required this.tichCuc,
    required this.tieuCuc,
    required this.trungLap,
    required this.diemNps,
  });

  factory ChiSoNps.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final aiNhanDien = data['ai_nhan_dien'] ?? {};
    return ChiSoNps(
      tichCuc: aiNhanDien['tich_cuc'] ?? 0,
      tieuCuc: aiNhanDien['tieu_cuc'] ?? 0,
      trungLap: aiNhanDien['trung_lap'] ?? 0,
      diemNps: data['chi_so_nps']?['diem'] ?? 0,
    );
  }
}
