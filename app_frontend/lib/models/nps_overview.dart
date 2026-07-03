class ChiSoNps {
  final int tongBinhLuan;
  final int tichCuc;
  final int tieuCuc;
  final int diemNps;

  ChiSoNps({required this.tongBinhLuan, required this.tichCuc, required this.tieuCuc, required this.diemNps});

  factory ChiSoNps.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final ai = data['ai_nhan_dien'] ?? {};
    final nps = data['chi_so_nps'] ?? {};
    return ChiSoNps(
      tongBinhLuan: data['tong_binh_luan'] ?? 0,
      tichCuc: ai['tich_cuc'] ?? 0,
      tieuCuc: ai['tieu_cuc'] ?? 0,
      diemNps: nps['diem'] ?? 0,
    );
  }
}