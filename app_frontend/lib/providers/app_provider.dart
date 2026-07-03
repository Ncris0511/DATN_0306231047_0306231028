import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
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

  Map<String, dynamic>? guestUser;
  Map<String, dynamic>? currentUser;
  Map<String, dynamic>? adminUser;

  bool get isLoggedUser => currentUser != null;
  bool get isAdmin => adminUser != null;

  List<ChuDeModel> danhSachChuDe = [];
  ChuDeModel? chuDeHienTai;
  List<KetQuaAI> cuocHoiThoaiHienTai = [];

  ChiSoNps? chiSoNps;
  List<DiemThoiGian> danhSachDiemThoiGian = [];
  String boLocThoiGianHienTai = '7_ngay';

  AppProvider() { _kiemTraDangNhapCu(); }

  Future<void> _kiemTraDangNhapCu() async {
    final prefs = await SharedPreferences.getInstance();
    
    final adminName = prefs.getString('admin_ho_ten');
    if (adminName != null) adminUser = {'ho_ten': adminName, 'vai_tro': prefs.getString('admin_vai_tro')};

    final userName = prefs.getString('user_ho_ten');
    if (userName != null) {
      currentUser = {'id': prefs.getInt('user_id'), 'ho_ten': userName, 'email': prefs.getString('user_email')};
      await taiDanhSachChuDe();
    } else {
      khoiChayPhienKhach();
    }
    notifyListeners();
  }

  // --- AUTH CLIENT ---
  Future<void> khoiChayPhienKhach() async {
    try {
      String deviceId = 'unknown_device_id';
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) deviceId = (await deviceInfo.androidInfo).id;
      else if (Platform.isIOS) deviceId = (await deviceInfo.iosInfo).identifierForVendor ?? 'ios';
      
      final userData = await _apiService.loginGuest(deviceId);
      if (userData != null) {
        guestUser = userData;
        await taiDanhSachChuDe();
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> dangNhapClient(String email, String pwd) async {
    isLoading = true; errorMessage = null; notifyListeners();
    final user = await _apiService.loginClient(email, pwd);
    if (user != null) {
      currentUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user['id']);
      await prefs.setString('user_ho_ten', user['ho_ten']);
      await prefs.setString('user_email', user['email']);
      await taiDanhSachChuDe();
      isLoading = false; notifyListeners();
      return true;
    }
    isLoading = false; errorMessage = 'Sai email hoặc mật khẩu!'; notifyListeners();
    return false;
  }

  Future<void> dangXuatClient() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id'); await prefs.remove('user_ho_ten'); await prefs.remove('user_email');
    danhSachChuDe.clear(); chuDeHienTai = null; cuocHoiThoaiHienTai.clear();
    khoiChayPhienKhach();
  }

  // --- CHAT LOGIC ---
  Future<void> taiDanhSachChuDe() async {
    final targetId = currentUser?['id'] ?? guestUser?['id'];
    if (targetId == null) return;
    danhSachChuDe = await _apiService.layDanhSachSidebar(targetId);
    if (danhSachChuDe.isNotEmpty && chuDeHienTai == null) await chonPhienChuDe(danhSachChuDe.first);
    notifyListeners();
  }

  Future<void> taoChuDeMoi(String tenChuDe) async {
    final targetId = currentUser?['id'] ?? guestUser?['id'];
    if (targetId == null) return;
    isLoading = true; notifyListeners();
    final newTopic = await _apiService.taoChuDeMoi(targetId, tenChuDe);
    if (newTopic != null) { danhSachChuDe.insert(0, newTopic); await chonPhienChuDe(newTopic); }
    isLoading = false; notifyListeners();
  }

  Future<void> chonPhienChuDe(ChuDeModel chuDe) async {
    chuDeHienTai = chuDe; isLoading = true; notifyListeners();
    cuocHoiThoaiHienTai = await _apiService.layChiTietPhienChat(chuDe.id);
    isLoading = false; notifyListeners();
  }

  Future<void> guiBinhLuanVaPhanTich(String noiDung, {File? imageFile}) async {
    if (chuDeHienTai == null) return;
    isAnalyzing = true; notifyListeners();
    try {
      String? base64Str; String? fName;
      if (imageFile != null) {
        base64Str = base64Encode(await imageFile.readAsBytes());
        fName = imageFile.path.split('/').last;
      }
      final res = await _apiService.phanTichBinhLuan(noiDung: noiDung, idChuDe: chuDeHienTai!.id, imageBase64: base64Str, fileName: fName);
      if (res != null) cuocHoiThoaiHienTai.add(res);
    } catch (_) {}
    isAnalyzing = false; notifyListeners();
  }

  // --- ADMIN LOGIC ---
  Future<bool> dangNhapAdmin(String usr, String pwd) async {
    isLoading = true; notifyListeners();
    final user = await _apiService.loginAdmin(usr, pwd);
    if (user != null && user['vai_tro'] == 'quan_tri') {
      adminUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_ho_ten', user['ho_ten']);
      await prefs.setString('admin_vai_tro', user['vai_tro']);
      isLoading = false; notifyListeners(); return true;
    }
    isLoading = false; notifyListeners(); return false;
  }

  Future<void> dangXuatAdmin() async {
    adminUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_ho_ten'); await prefs.remove('admin_vai_tro');
    notifyListeners();
  }

  Future<void> taiDuLieuDashboard() async {
    isLoading = true; notifyListeners();
    final results = await Future.wait([_apiService.layChiSoNps(), _apiService.layThongKeThoiGian(locTheo: boLocThoiGianHienTai)]);
    chiSoNps = results[0] as ChiSoNps?; danhSachDiemThoiGian = (results[1] as List<DiemThoiGian>?) ?? [];
    isLoading = false; notifyListeners();
  }
}