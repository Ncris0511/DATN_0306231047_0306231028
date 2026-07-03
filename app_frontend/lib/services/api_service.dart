import 'package:dio/dio.dart';
import '../utils/app_config.dart';
import '../models/sentiment_result.dart';
import '../models/nps_overview.dart';
import '../models/time_point.dart';
import '../models/chu_de_model.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl, connectTimeout: const Duration(seconds: 15), headers: {'Content-Type': 'application/json'}));
  }

  // --- CLIENT AUTH ---
  Future<Map<String, dynamic>?> loginGuest(String deviceId) async {
    try {
      final res = await _dio.post('/auth/guest', data: {'device_id': deviceId});
      if (res.statusCode == 200 && res.data['success'] == true) return res.data['data'];
    } catch (_) {}
    return null;
  }

  // --- CLIENT AUTH ---
  Future<Map<String, dynamic>?> loginClient(String email, String password) async {
    try {
      final res = await _dio.post('/auth/login', data: {'email': email, 'mat_khau': password});
      if (res.statusCode == 200 && res.data['success'] == true) return res.data['data'];
    } on DioException catch (e) {
      // IN LỖI RA ĐỂ BẮT BỆNH
      print("LỖI ĐĂNG NHẬP API: ${e.response?.statusCode} - ${e.response?.data}");
    } catch (e) {
      print("LỖI ĐĂNG NHẬP HỆ THỐNG: $e");
    }
    return null;
  }

  Future<bool> registerClient(String hoTen, String email, String password) async {
    try {
      final res = await _dio.post('/auth/register', data: {'ho_ten': hoTen, 'email': email, 'mat_khau': password});
      if (res.statusCode == 201) return true;
    } on DioException catch (e) {
      // IN LỖI RA ĐỂ BẮT BỆNH
      print("LỖI ĐĂNG KÝ API: ${e.response?.statusCode} - ${e.response?.data}");
    } catch (e) {
      print("LỖI ĐĂNG KÝ HỆ THỐNG: $e");
    }
    return false;
  }

  // --- CHAT & SIDEBAR ---
  Future<ChuDeModel?> taoChuDeMoi(int idTaiKhoan, String tenChuDe) async {
    try {
      final res = await _dio.post('/sidebar/tao-moi', data: {'id_tai_khoan': idTaiKhoan, 'ten_chu_de': tenChuDe});
      if (res.statusCode == 201) return ChuDeModel.fromJson(res.data['data']);
    } catch (_) {}
    return null;
  }

  Future<List<ChuDeModel>> layDanhSachSidebar(int idTaiKhoan) async {
    try {
      final res = await _dio.get('/sidebar/danh-sach', queryParameters: {'id_tai_khoan': idTaiKhoan});
      if (res.statusCode == 200) return (res.data['data'] as List).map((e) => ChuDeModel.fromJson(e)).toList();
    } catch (_) {}
    return [];
  }

  Future<List<KetQuaAI>> layChiTietPhienChat(int idChuDe) async {
    try {
      final res = await _dio.get('/sidebar/chi-tiet/$idChuDe');
      if (res.statusCode == 200) return (res.data['data'] as List).map((e) => KetQuaAI.fromJson(e)).toList();
    } catch (_) {}
    return [];
  }

  Future<KetQuaAI?> phanTichBinhLuan({required String noiDung, required int idChuDe, String? imageBase64, String? fileName}) async {
    try {
      final data = {'noi_dung': noiDung, 'id_chu_de': idChuDe};
      if (imageBase64 != null) { data['image_base64'] = imageBase64; data['file_name'] = fileName ?? 'image.jpg'; }
      final res = await _dio.post('/binh-luan/phan-tich', data: data);
      if (res.statusCode == 200) return KetQuaAI.fromJson(res.data['data']);
    } catch (_) {}
    return null;
  }

  // --- ADMIN ---
  Future<Map<String, dynamic>?> loginAdmin(String usr, String pwd) async {
    try {
      final res = await _dio.post('/admin/login', data: {'ten_dang_nhap': usr, 'mat_khau': pwd});
      if (res.statusCode == 200 && res.data['success'] == true) return res.data['data'];
    } catch (_) {}
    return null;
  }

  Future<ChiSoNps?> layChiSoNps() async {
    try {
      final res = await _dio.get('/admin/chi-so-nps');
      if (res.statusCode == 200) return ChiSoNps.fromJson(res.data);
    } catch (_) {}
    return null;
  }

  Future<List<DiemThoiGian>> layThongKeThoiGian({String locTheo = '7_ngay'}) async {
    try {
      final res = await _dio.get('/admin/thong-ke-thoi-gian', queryParameters: {'loc_theo': locTheo});
      if (res.statusCode == 200) return (res.data['data'] as List).map((e) => DiemThoiGian.fromJson(e)).toList();
    } catch (_) {}
    return [];
  }
}