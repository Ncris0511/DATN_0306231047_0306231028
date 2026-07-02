import 'dart:io';
import 'package:dio/dio.dart'; // <--- Đã thêm thư viện Dio bị thiếu
import 'package:path_provider/path_provider.dart';
import '../utils/app_config.dart';
import '../models/sentiment_result.dart';
import '../models/nps_overview.dart';
import '../models/time_point.dart';
import '../models/chu_de_model.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 90),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  // 1. Định danh Khách (Guest Onboarding)
  Future<Map<String, dynamic>?> loginGuest(String deviceId) async {
    try {
      final res = await _dio.post('/auth/guest', data: {'device_id': deviceId});
      if (res.statusCode == 200 && res.data['success'] == true) {
        return res.data['data'];
      }
      return null;
    } catch (e) {
      throw 'Không thể định danh thiết bị: $e';
    }
  }

  // 2. Tạo chủ đề mới (Sidebar)
  Future<ChuDeModel?> taoChuDeMoi(int idTaiKhoan, String tenChuDe) async {
    try {
      final res = await _dio.post(
        '/sidebar/tao-moi',
        data: {'id_tai_khoan': idTaiKhoan, 'ten_chu_de': tenChuDe},
      );
      if (res.statusCode == 201 && res.data['success'] == true) {
        return ChuDeModel.fromJson(res.data['data']);
      }
      return null;
    } catch (e) {
      throw 'Lỗi tạo chủ đề mới: $e';
    }
  }

  // 3. Lấy danh sách Sidebar
  Future<List<ChuDeModel>> layDanhSachSidebar(int idTaiKhoan) async {
    try {
      final res = await _dio.get('/sidebar/danh-sach', queryParameters: {'id_tai_khoan': idTaiKhoan});
      if (res.statusCode == 200 && res.data['success'] == true) {
        List list = res.data['data'] ?? [];
        return list.map((e) => ChuDeModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 4. Lấy chi tiết phiên chat
  Future<List<KetQuaAI>> layChiTietPhienChat(int idChuDe) async {
    try {
      final res = await _dio.get('/sidebar/chi-tiet/$idChuDe');
      if (res.statusCode == 200 && res.data['success'] == true) {
        List list = res.data['data'] ?? [];
        return list.map((e) => KetQuaAI.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 5. Hội chẩn AI
  Future<Map<String, dynamic>?> hoiChanAI(int idChuDe) async {
    try {
      final res = await _dio.post('/sidebar/hoi-chan/$idChuDe');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return res.data['data'];
      }
      return null;
    } catch (e) {
      throw 'Lỗi hội chẩn: $e';
    }
  }

  // 6. Phân tích bình luận (Hỗ trợ ảnh Multimodal)
  Future<KetQuaAI?> phanTichBinhLuan({
    required String noiDung,
    required int idChuDe,
    String? imageBase64,
    String? mimeType,
    String? fileName,
  }) async {
    try {
      final Map<String, dynamic> postData = {
        'noi_dung': noiDung.trim(),
        'id_chu_de': idChuDe,
      };

      if (imageBase64 != null) {
        postData['image_base64'] = imageBase64;
        postData['file_mime_type'] = mimeType ?? 'image/jpeg';
        postData['hinh_anh_dinh_kem'] = fileName ?? 'flutter_upload.jpg';
      }

      final res = await _dio.post('/binh-luan/phan-tich', data: postData);
      if (res.statusCode == 200 && res.data['success'] == true) {
        return KetQuaAI.fromJson(res.data['data']);
      }
      return null;
    } catch (e) {
      throw 'Lỗi kết nối AI: $e';
    }
  }

  // 7. Admin: Thống kê Dashboard
  Future<ChiSoNps?> layChiSoNps() async {
    try {
      final res = await _dio.get('/binh-luan/thong-ke');
      return ChiSoNps.fromJson(res.data);
    } catch (e) {
      return null;
    }
  }

  // 8. Admin: Thống kê thời gian
  Future<List<DiemThoiGian>> layThongKeThoiGian({required String locTheo}) async {
    try {
      final res = await _dio.get('/admin/thong-ke-thoi-gian', queryParameters: {'loc_theo': locTheo});
      if (res.data != null && res.data['data'] is List) {
        List l = res.data['data'];
        return l.map((x) => DiemThoiGian.fromJson(x)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // 9. Admin: Danh sách bình luận
  Future<List<KetQuaAI>> layDanhSachBinhLuan() async {
    try {
      final res = await _dio.get('/admin/binh-luan-danh-sach');
      if (res.statusCode == 200 && res.data != null && res.data['data'] is List) {
        List l = res.data['data'];
        return l.map((x) => KetQuaAI.fromJson(x)).toList();
      }
    } catch (_) {}
    return [];
  }

  // 10. Admin: Đăng nhập
  Future<Map<String, dynamic>?> loginAdmin(String usr, String pwd) async {
    try {
      final res = await _dio.post('/admin/login', data: {'ten_dang_nhap': usr, 'mat_khau': pwd});
      if (res.statusCode == 200 && res.data['success'] == true) {
        return res.data['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 11. Admin: Tải báo cáo
  Future<String?> taiFileBaoCaoExcel() async {
    final fileName = 'BaoCao_SentiFlow_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    String targetPath;
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      targetPath = '${dir!.path}/$fileName';
    } else {
      final dir = await getApplicationDocumentsDirectory();
      targetPath = '${dir.path}/$fileName';
    }

    try {
      await _dio.download('/admin/xuat-excel', targetPath);
      return targetPath;
    } catch (e) {
      return null;
    }
  }
}