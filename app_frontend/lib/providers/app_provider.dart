import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sentiment_result.dart';
import '../models/nps_overview.dart';
import '../models/time_point.dart';
import '../models/chu_de_model.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool isLoading = false;
  bool isAnalyzing = false;
  String? errorMessage;
  bool isDarkMode = false;
  String? deviceIdMacDinh;
  bool isInitDone = false;

  Map<String, dynamic>? guestUser;
  Map<String, dynamic>? currentUser;
  Map<String, dynamic>? adminUser;

  bool get isLoggedUser => currentUser != null;
  bool get isAdmin => adminUser != null;

  List<ChuDeModel> danhSachChuDe = [];
  List<ChuDeModel> danhSachChuDeGoc = [];
  String tuKhoaTimKiem = '';
  ChuDeModel? chuDeHienTai;
  List<KetQuaAI> cuocHoiThoaiHienTai = [];

  ChiSoNps? chiSoNps;
  List<DiemThoiGian> danhSachDiemThoiGian = [];
  String boLocThoiGianHienTai = '7_ngay';

  AppProvider() {
    _kiemTraDangNhapCu();
  }

  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDarkMode);
  }

  Future<void> _kiemTraDangNhapCu() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    deviceIdMacDinh = prefs.getString('device_id');

    if (deviceIdMacDinh == null || deviceIdMacDinh!.isEmpty) {
      deviceIdMacDinh = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_id', deviceIdMacDinh!);
    }

    final adminName = prefs.getString('admin_ho_ten');
    if (adminName != null) {
      adminUser = {
        'ho_ten': adminName,
        'vai_tro': prefs.getString('admin_vai_tro'),
      };
    }

    final userName = prefs.getString('user_ho_ten');
    if (userName != null) {
      currentUser = {
        'id': prefs.getInt('user_id'),
        'ho_ten': userName,
        'email': prefs.getString('user_email'),
      };
      await taiDanhSachChuDe();
    } else {
      await khoiChayPhienKhach();
    }
    isInitDone = true;
    notifyListeners();
  }

  Future<void> khoiChayPhienKhach() async {
    try {
      final userData = await _apiService.loginGuest(
        deviceIdMacDinh ?? 'unknown',
      );
      if (userData != null) {
        guestUser = userData;
        await taiDanhSachChuDe();
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> dangNhapClient(String email, String pwd) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final user = await _apiService.loginClient(email, pwd, deviceIdMacDinh);

    if (user != null) {
      currentUser = user;
      guestUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user['id']);
      await prefs.setString('user_ho_ten', user['ho_ten']);
      await prefs.setString('user_email', email);
      deviceIdMacDinh = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_id', deviceIdMacDinh!);
      await taiDanhSachChuDe();
      if (chuDeHienTai != null) {
        try {
          chuDeHienTai = danhSachChuDeGoc.firstWhere(
            (c) => c.id == chuDeHienTai!.id,
          );
        } catch (_) {
          chuDeHienTai = null;
          cuocHoiThoaiHienTai.clear();
        }
      }
      isLoading = false;
      notifyListeners();
      return true;
    }
    isLoading = false;
    errorMessage = 'Sai email hoặc mật khẩu!';
    notifyListeners();
    return false;
  }

  Future<bool> doiMatKhauUser(String cu, String moi) async {
    if (currentUser == null) return false;
    isLoading = true;
    notifyListeners();
    final success = await _apiService.doiMatKhau(currentUser!['id'], cu, moi);
    isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> capNhatHoTenUser(String tenMoi) async {
    if (currentUser == null) return false;
    isLoading = true;
    notifyListeners();
    final success = await _apiService.capNhatThongTin(
      currentUser!['id'],
      tenMoi,
    );
    if (success) {
      currentUser!['ho_ten'] = tenMoi;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_ho_ten', tenMoi);
    }
    isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> dangXuatClient() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_ho_ten');
    await prefs.remove('user_email');

    // Đổi thẻ từ mới cho Khách ẩn danh
    deviceIdMacDinh = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString('device_id', deviceIdMacDinh!);

    // [ĐÃ FIX]: Dọn sạch rác bộ nhớ của User để không bị trôi dữ liệu
    danhSachChuDe.clear();
    danhSachChuDeGoc.clear();
    chuDeHienTai = null;
    cuocHoiThoaiHienTai.clear();

    await khoiChayPhienKhach();
  }

  Future<void> taiDanhSachChuDe() async {
    final targetId = currentUser?['id'] ?? guestUser?['id'];
    if (targetId == null) return;
    danhSachChuDeGoc = await _apiService.layDanhSachSidebar(targetId);
    _locDanhSachChuDe();
  }

  void timKiemChuDe(String keyword) {
    tuKhoaTimKiem = keyword.toLowerCase();
    _locDanhSachChuDe();
  }

  void _locDanhSachChuDe() {
    if (tuKhoaTimKiem.isEmpty) {
      danhSachChuDe = List.from(danhSachChuDeGoc);
    } else {
      danhSachChuDe = danhSachChuDeGoc
          .where((c) => c.tenChuDe.toLowerCase().contains(tuKhoaTimKiem))
          .toList();
    }
    notifyListeners();
  }

  Future<void> taoChuDeMoi(String tenChuDe) async {
    final targetId = currentUser?['id'] ?? guestUser?['id'];
    if (targetId == null) return;
    isLoading = true;
    notifyListeners();
    final newTopic = await _apiService.taoChuDeMoi(targetId, tenChuDe);
    if (newTopic != null) {
      danhSachChuDe.insert(0, newTopic);
      await chonPhienChuDe(newTopic);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> xoaChuDeX(int idChuDe) async {
    final targetId = currentUser?['id'] ?? guestUser?['id'];
    if (targetId == null) return;
    final thanhCong = await _apiService.xoaChuDe(idChuDe, targetId);
    if (thanhCong) {
      danhSachChuDeGoc.removeWhere((c) => c.id == idChuDe);
      _locDanhSachChuDe();
      if (chuDeHienTai?.id == idChuDe) {
        chuDeHienTai = null;
        cuocHoiThoaiHienTai.clear();
      }
      notifyListeners();
    }
  }

  Future<void> chonPhienChuDe(ChuDeModel chuDe) async {
    chuDeHienTai = chuDe;
    isLoading = true;
    notifyListeners();
    cuocHoiThoaiHienTai = await _apiService.layChiTietPhienChat(chuDe.id);
    isLoading = false;
    notifyListeners();
  }

  Future<void> guiBinhLuanVaPhanTich(
    String noiDung, {
    File? fileDinhKem,
    bool isImage = true,
  }) async {
    if (chuDeHienTai == null) return;
    final textGuiDi = noiDung.trim().isEmpty
        ? "Hãy phân tích tài liệu đính kèm này."
        : noiDung.trim();
    final tinNhanTam = KetQuaAI(
      id: DateTime.now().millisecondsSinceEpoch,
      noiDung: textGuiDi,
      nhanCamXuc: 'CHUA_PHAN_LOAI',
      doTinCay: 0.0,
      lyDoCuaAI: '',
      tieuChiTinCay: '',
      danhGiaSao: 0,
      lyDoDanhGiaSao: '',
      danhSachKhiaCanh: [],
    );
    cuocHoiThoaiHienTai.add(tinNhanTam);
    isAnalyzing = true;
    notifyListeners();

    try {
      String? base64Str;
      String? fName;
      if (fileDinhKem != null) {
        base64Str = base64Encode(await fileDinhKem.readAsBytes());
        fName = fileDinhKem.path.split('/').last;
      }
      final res = await _apiService.phanTichBinhLuan(
        noiDung: textGuiDi,
        idChuDe: chuDeHienTai!.id,
        imageBase64: isImage ? base64Str : null,
        fileName: fName,
      );
      cuocHoiThoaiHienTai.removeLast();

      if (res != null) {
        cuocHoiThoaiHienTai.add(res);
        chuDeHienTai = ChuDeModel(
          id: chuDeHienTai!.id,
          idTaiKhoan: chuDeHienTai!.idTaiKhoan,
          tenChuDe: chuDeHienTai!.tenChuDe,
          phanQuyetAi: 'CHUA_HOI_CHAN',
          tomTatAi: null,
        );
        final index = danhSachChuDe.indexWhere((c) => c.id == chuDeHienTai!.id);
        if (index != -1) danhSachChuDe[index] = chuDeHienTai!;
      } else {
        cuocHoiThoaiHienTai.add(
          KetQuaAI(
            id: -1,
            noiDung: textGuiDi,
            nhanCamXuc: 'TIEU_CUC',
            doTinCay: 0.0,
            lyDoCuaAI: '⚠ LỖI: Máy chủ không trả về dữ liệu.',
            tieuChiTinCay: '',
          ),
        );
      }
    } catch (e) {
      cuocHoiThoaiHienTai.removeLast();
      cuocHoiThoaiHienTai.add(
        KetQuaAI(
          id: -1,
          noiDung: textGuiDi,
          nhanCamXuc: 'TIEU_CUC',
          doTinCay: 0.0,
          lyDoCuaAI:
              '⚠ LỖI TỪ SERVER: ${e.toString().replaceAll('Exception: ', '')}',
          tieuChiTinCay: '',
        ),
      );
    }
    isAnalyzing = false;
    notifyListeners();
  }

  Future<bool> goiHoiChanChotHa({bool anLoading = false}) async {
    if (chuDeHienTai == null) return false;
    if (!anLoading) {
      isLoading = true;
      notifyListeners();
    }
    final ketQua = await _apiService.hoiChanPhienChat(chuDeHienTai!.id);
    bool success = false;
    if (ketQua != null) {
      chuDeHienTai = ChuDeModel(
        id: chuDeHienTai!.id,
        idTaiKhoan: chuDeHienTai!.idTaiKhoan,
        tenChuDe: chuDeHienTai!.tenChuDe,
        phanQuyetAi: ketQua['phan_quyet_ai'],
        tomTatAi: ketQua['tom_tat_ai'],
      );
      final index = danhSachChuDe.indexWhere((c) => c.id == chuDeHienTai!.id);
      if (index != -1) danhSachChuDe[index] = chuDeHienTai!;
      success = true;
    }
    if (!anLoading) {
      isLoading = false;
      notifyListeners();
    }
    return success;
  }

  Future<bool> dangNhapAdmin(String usr, String pwd) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final user = await _apiService.loginAdmin(usr, pwd);
    if (user != null && user['vai_tro'] == 'quan_tri') {
      adminUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_ho_ten', user['ho_ten']);
      await prefs.setString('admin_vai_tro', user['vai_tro']);
      isLoading = false;
      notifyListeners();
      return true;
    }
    errorMessage = 'Tài khoản không tồn tại hoặc không có quyền Admin!';
    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> dangXuatAdmin() async {
    adminUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_ho_ten');
    await prefs.remove('admin_vai_tro');

    // [ĐÃ FIX]: Dọn sạch rác bộ nhớ của Admin để không bị lộ sang Khách
    danhSachChuDe.clear();
    danhSachChuDeGoc.clear();
    chuDeHienTai = null;
    cuocHoiThoaiHienTai.clear();
    chiSoNps = null;
    danhSachDiemThoiGian.clear();

    notifyListeners();
  }

  Future<void> taiDuLieuDashboard() async {
    isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _apiService.layChiSoNps(locTheo: boLocThoiGianHienTai),
        _apiService.layThongKeThoiGian(locTheo: boLocThoiGianHienTai),
        _apiService.layThongKeSanPhamAdmin(locTheo: boLocThoiGianHienTai),
      ]);

      chiSoNps = results[0] as ChiSoNps?;
      danhSachDiemThoiGian = (results[1] as List<DiemThoiGian>?) ?? [];
      danhSachChuDeGoc = (results[2] as List<ChuDeModel>?) ?? [];
      danhSachChuDe = List.from(danhSachChuDeGoc);
    } catch (e) {
      print("Lỗi tải Dashboard: $e");
    }
    isLoading = false;
    notifyListeners();
  }
}
