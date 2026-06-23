import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/app_config.dart';
import '../models/sentiment_result.dart';
import '../models/nps_overview.dart';
import '../models/time_point.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<KetQuaAI?> phanTichBinhLuan(String noiDung) async {
    try {
      final res = await _dio.post(
        '/binh-luan/phan-tich',
        data: {'noi_dung': noiDung.trim()},
      );
      if (res.statusCode == 200 && res.data['success'] == true) {
        return KetQuaAI.fromJson(res.data['data']);
      }
      return null;
    } catch (e) {
      throw 'Lỗi kết nối AI: $e';
    }
  }

  Future<ChiSoNps?> layChiSoNps() async {
    try {
      final res = await _dio.get('/binh-luan/thong-ke');
      if (res.statusCode == 200 && res.data['success'] == true)
        return ChiSoNps.fromJson(res.data);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<DiemThoiGian>> layThongKeThoiGian({
    String locTheo = '7_ngay',
  }) async {
    try {
      final res = await _dio.get(
        '/admin/thong-ke-thoi-gian',
        queryParameters: {'loc_theo': locTheo},
      );
      if (res.statusCode == 200 && res.data['success'] == true) {
        final rawList = res.data['data'] as List?;
        if (rawList == null) return [];
        return rawList.map((item) => DiemThoiGian.fromJson(item)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> dangNhapAdmin(String usr, String pwd) async {
    try {
      final res = await _dio.post(
        '/admin/login',
        data: {'ten_dang_nhap': usr.trim(), 'mat_khau': pwd.trim()},
      );
      if (res.statusCode == 200 && res.data['success'] == true)
        return res.data['data'];
      return null;
    } catch (_) {
      return null;
    }
  }

  // =========================================================================
  // ⚠️ ĐÃ NẠP CHÍNH XÁC ROUTER DÒNG 19 TRONG api.js CỦA BẠN:
  // =========================================================================
  Future<List<KetQuaAI>> layDanhSachBinhLuan() async {
    final endpoints = [
      '/admin/binh-luan-danh-sach', // <--- Cánh cửa đích thực!
      '/admin/binh-luan',
      '/binh-luan/danh-sach',
    ];

    for (final path in endpoints) {
      try {
        final res = await _dio.get(path);
        if (res.statusCode == 200 && res.data != null) {
          final raw = res.data;
          List rawList = [];
          if (raw is Map && raw['data'] is List) {
            rawList = raw['data'] as List;
          } else if (raw is List) {
            rawList = raw;
          }
          if (rawList.isNotEmpty) {
            return rawList
                .map((x) {
                  try {
                    return KetQuaAI.fromJson(x as Map<String, dynamic>);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<KetQuaAI>()
                .toList();
          }
        }
      } catch (_) {}
    }
    return [];
  }

  Future<String> get publicDownloadPath async {
    final fileName =
        'BaoCao_SentiFlow_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download/$fileName';
    }
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$fileName';
  }

  String get urlXuatExcel => '${AppConfig.baseUrl}/admin/xuat-bao-cao';
}
