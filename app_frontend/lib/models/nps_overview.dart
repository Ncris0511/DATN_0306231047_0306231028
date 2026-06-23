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
    // Luồn lách an toàn qua các tầng JSON của Node.js:
    final data = json['data'] ?? {};
    final ai = data['ai_nhan_dien'] ?? {};
    final nps = data['chi_so_nps'] ?? {};

    return ChiSoNps(
      tongBinhLuan: data['tong_binh_luan'] ?? 0,
      tichCuc: ai['tich_cuc'] ?? 0,
      tieuCuc: ai['tieu_cuc'] ?? 0,
      trungLap: ai['trung_lap'] ?? 0,
      diemNps: nps['diem'] ?? 0,
      chanDoan: nps['chan_doan_suckhoe'] ?? 'Chưa có dữ liệu chẩn đoán',
      mauSacUi: nps['mau_sac_ui'] ?? '0xFF2196F3',
      thoiGianTbMs: data['thoi_gian_tb_ms'] ?? 0,
    );
  }
}
