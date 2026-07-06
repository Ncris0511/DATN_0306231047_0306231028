import 'package:dio/dio.dart';
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
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<Map<String, dynamic>?> loginGuest(String deviceId) async {
    try {
      final res = await _dio.post('/auth/guest', data: {'device_id': deviceId});
      if (res.statusCode == 200 && res.data['success'] == true)
        return res.data['data'];
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> loginClient(
    String email,
    String password,
    String? deviceId,
  ) async {
    try {
      final res = await _dio.post(
        '/auth/login',
        data: {'email': email, 'mat_khau': password, 'device_id': deviceId},
      );
      if (res.statusCode == 200 && res.data['success'] == true)
        return res.data['data'];
    } catch (_) {}
    return null;
  }

  Future<bool> registerClient(
    String hoTen,
    String email,
    String soDienThoai,
    String password,
    String? deviceId,
  ) async {
    try {
      final res = await _dio.post(
        '/auth/register',
        data: {
          'ho_ten': hoTen,
          'email': email,
          'so_dien_thoai': soDienThoai,
          'mat_khau': password,
          'device_id': deviceId,
        },
      );
      if (res.statusCode == 201 || res.statusCode == 200) return true;
    } catch (_) {}
    return false;
  }

  Future<bool> doiMatKhau(
    int idTaiKhoan,
    String matKhauCu,
    String matKhauMoi,
  ) async {
    try {
      final res = await _dio.put(
        '/auth/doi-mat-khau',
        data: {
          'id_tai_khoan': idTaiKhoan,
          'mat_khau_cu': matKhauCu,
          'mat_khau_moi': matKhauMoi,
        },
      );
      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<bool> capNhatThongTin(int idTaiKhoan, String hoTen) async {
    try {
      final res = await _dio.put(
        '/auth/cap-nhat-thong-tin',
        data: {'id_tai_khoan': idTaiKhoan, 'ho_ten': hoTen},
      );
      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<ChuDeModel?> taoChuDeMoi(int idTaiKhoan, String tenChuDe) async {
    try {
      final res = await _dio.post(
        '/sidebar/tao-moi',
        data: {'id_tai_khoan': idTaiKhoan, 'ten_chu_de': tenChuDe},
      );
      if (res.statusCode == 201) return ChuDeModel.fromJson(res.data['data']);
    } catch (_) {}
    return null;
  }

  Future<List<ChuDeModel>> layDanhSachSidebar(int idTaiKhoan) async {
    try {
      final res = await _dio.get(
        '/sidebar/danh-sach',
        queryParameters: {'id_tai_khoan': idTaiKhoan},
      );
      if (res.statusCode == 200)
        return (res.data['data'] as List)
            .map((e) => ChuDeModel.fromJson(e))
            .toList();
    } catch (_) {}
    return [];
  }

  Future<bool> xoaChuDe(int idChuDe, int idTaiKhoan) async {
    try {
      final res = await _dio.delete(
        '/sidebar/xoa/$idChuDe',
        queryParameters: {'id_tai_khoan': idTaiKhoan},
      );
      if (res.statusCode == 200 || res.statusCode == 204) return true;
    } catch (_) {}
    return false;
  }

  Future<List<KetQuaAI>> layChiTietPhienChat(int idChuDe) async {
    try {
      final res = await _dio.get('/sidebar/chi-tiet/$idChuDe');
      if (res.statusCode == 200) {
        final mangDuLieu =
            res.data['lich_su_hoi_thoai'] ?? res.data['data'] ?? res.data;
        if (mangDuLieu is List)
          return mangDuLieu.map((e) => KetQuaAI.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<KetQuaAI?> phanTichBinhLuan({
    required String noiDung,
    required int idChuDe,
    String? imageBase64,
    String? fileName,
  }) async {
    try {
      final data = {'noi_dung': noiDung, 'id_chu_de': idChuDe};
      if (imageBase64 != null) {
        data['image_base64'] = imageBase64;
        data['file_name'] = fileName ?? 'image.jpg';
      }
      final res = await _dio.post('/binh-luan/phan-tich', data: data);
      if (res.statusCode == 200) return KetQuaAI.fromJson(res.data['data']);
    } catch (e) {
      String serverMsg = e.toString();
      if (e is DioException)
        serverMsg = e.response?.data['message'] ?? e.message;
      throw Exception(serverMsg);
    }
  }

  Future<Map<String, dynamic>?> hoiChanPhienChat(int idChuDe) async {
    try {
      final res = await _dio.post('/sidebar/hoi-chan/$idChuDe');
      if (res.statusCode == 200) return res.data['ket_qua_chot_ha'];
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> loginAdmin(String email, String pwd) async {
    try {
      final res = await _dio.post(
        '/admin/login',
        data: {'email': email, 'mat_khau': pwd},
      );
      if (res.statusCode == 200 && res.data['success'] == true)
        return res.data['data'];
    } catch (_) {}
    return null;
  }

  // =========================================================================
  // FIX LỖI: BỌC THÉP 3 HÀM DỮ LIỆU ĐỂ LUÔN ĐỌC ĐÚNG JSON VÀ MANG THEO BIẾN
  // =========================================================================
  Future<ChiSoNps?> layChiSoNps({String locTheo = '7_ngay'}) async {
    try {
      final res = await _dio.get(
        '/admin/chi-so-nps',
        queryParameters: {'loc_theo': locTheo},
      );
      if (res.statusCode == 200 && res.data['success'] == true) {
        // Fix: Bóc tách đúng tầng 'data'
        final dynamic data = res.data['data'] ?? res.data;
        return ChiSoNps.fromJson(data);
      }
    } catch (e) {
      print("Lỗi layChiSoNps: $e");
    }
    return null;
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
        return (res.data['data'] as List)
            .map((e) => DiemThoiGian.fromJson(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<ChuDeModel>> layThongKeSanPhamAdmin({
    String locTheo = '7_ngay',
  }) async {
    try {
      final res = await _dio.get(
        '/admin/thong-ke-san-pham',
        queryParameters: {'loc_theo': locTheo},
      );
      if (res.statusCode == 200 && res.data['success'] == true) {
        return (res.data['data'] as List)
            .map(
              (e) => ChuDeModel(
                id:
                    int.tryParse(
                      e['id_chu_de']?.toString() ?? e['id']?.toString() ?? '0',
                    ) ??
                    0,
                idTaiKhoan: 1,
                tenChuDe:
                    e['ten_chu_de']?.toString() ??
                    e['ten_san_pham']?.toString() ??
                    'Sản phẩm',
                phanQuyetAi:
                    e['phan_quyet_ai']?.toString() ??
                    e['phan_quyet_chot_ha']?.toString() ??
                    'CHUA_HOI_CHAN',
                tomTatAi: e['tom_tat_ai']?.toString(),
                soLuongBinhLuan:
                    int.tryParse(
                      e['so_luong_binh_luan']?.toString() ??
                          e['tong_binh_luan']?.toString() ??
                          '0',
                    ) ??
                    0,
              ),
            )
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
