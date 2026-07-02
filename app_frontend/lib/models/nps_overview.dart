class ChiSoNps {
  final int tongBinhLuan;
  final int tichCuc;
  final int tieuCuc;
  final int trungLap;
  final int diemNps;
  final String chanDoan;
  final String mauSacUi;
  final int thoiGianTbMs;

  ChiSoNps({
    required this.tongBinhLuan,
    required this.tichCuc,
    required this.tieuCuc,
    required this.trungLap,
    required this.diemNps,
    required this.chanDoan,
    required this.mauSacUi,
    required this.thoiGianTbMs,
  });

  factory ChiSoNps.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final ai = data['ai_nhan_dien'] ?? {};
    final nps = data['chi_so_nps'] ?? {};

    return ChiSoNps(
      tongBinhLuan: data['tong_binh_luan'] ?? 0,
      tichCuc: ai['tich_cuc'] ?? 0,
      tieuCuc: ai['tieu_cuc'] ?? 0,
      trungLap: ai['trung_lap'] ?? 0,
      diemNps: nps['diem'] ?? 0,
      chanDoan: nps['loi_chan_doan'] ?? '',
      mauSacUi: nps['ma_mau_hex'] ?? '0xFF2196F3',
      thoiGianTbMs: data['toc_do_phan_hoi'] ?? 0,
    );
  }
}