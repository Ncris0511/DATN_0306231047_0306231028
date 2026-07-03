class KetQuaAI {
  final int id;
  final String noiDung;
  final String nhanCamXuc;
  
  KetQuaAI({required this.id, required this.noiDung, required this.nhanCamXuc});

  factory KetQuaAI.fromJson(Map<String, dynamic> json) {
    return KetQuaAI(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      noiDung: json['noi_dung']?.toString() ?? json['noiDung']?.toString() ?? '',
      nhanCamXuc: json['nhan_cam_xuc']?.toString() ?? json['nhanCamXuc']?.toString() ?? 'TRUNG_LAP',
    );
  }
}