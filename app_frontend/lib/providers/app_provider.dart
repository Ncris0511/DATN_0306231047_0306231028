import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sentiment_result.dart';
import '../models/nps_overview.dart';
import '../models/time_point.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  String? errorMessage;

  KetQuaAI? ketQuaHienTai;
  ChiSoNps? chiSoNps;
  List<DiemThoiGian> danhSachDiemThoiGian = [];
  List<KetQuaAI> danhSachBinhLuan = [];

  String boLocThoiGianHienTai = '7_ngay';

  Map<String, dynamic>? adminUser;
  bool get isAdmin => adminUser != null;

  AppProvider() {
    _kiemTraDangNhapCu();
  }

  Future<void> _kiemTraDangNhapCu() async {
    final prefs = await SharedPreferences.getInstance();
    final hoTen = prefs.getString('admin_ho_ten');
    final vaiTro = prefs.getString('admin_vai_tro');
    if (hoTen != null && vaiTro == 'quan_tri') {
      adminUser = {'ho_ten': hoTen, 'vai_tro': vaiTro};
      notifyListeners();
    }
  }

  Future<bool> guiBinhLuanPhanTich(String noiDung) async {
    if (noiDung.trim().isEmpty) return false;
    isLoading = true;
    errorMessage = null;
    ketQuaHienTai = null;
    notifyListeners();
    try {
      final kq = await _apiService.phanTichBinhLuan(noiDung);
      if (kq != null) {
        ketQuaHienTai = kq;
        isLoading = false;
        notifyListeners();
        return true;
      }
      errorMessage = 'Không nhận được phản hồi từ Google Gemini.';
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> taiDuLieuDashboard() async {
    isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _apiService.layChiSoNps(),
        _apiService.layThongKeThoiGian(locTheo: boLocThoiGianHienTai),
        _apiService.layDanhSachBinhLuan(),
      ]);
      chiSoNps = results[0] as ChiSoNps?;
      danhSachDiemThoiGian = (results[1] as List<DiemThoiGian>?) ?? [];
      danhSachBinhLuan = (results[2] as List<KetQuaAI>?) ?? [];
    } catch (e) {
      errorMessage = 'Lỗi tải Dashboard: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> thayDoiMienThoiGian(String mienMoi) async {
    if (boLocThoiGianHienTai == mienMoi) return;
    boLocThoiGianHienTai = mienMoi;
    notifyListeners();
    final mang = await _apiService.layThongKeThoiGian(locTheo: mienMoi);
    danhSachDiemThoiGian = mang;
    notifyListeners();
  }

  Future<bool> dangNhapAdmin(String usr, String pwd) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final user = await _apiService.dangNhapAdmin(usr, pwd);
      if (user != null && user['vai_tro'] == 'quan_tri') {
        adminUser = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_ho_ten', user['ho_ten']);
        await prefs.setString('admin_vai_tro', user['vai_tro']);
        isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> dangXuatAdmin() async {
    adminUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
