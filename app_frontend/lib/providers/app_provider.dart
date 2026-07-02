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
  String? errorMessage;

  Map<String, dynamic>? guestUser;
  List<ChuDeModel> danhSachChuDe = [];
  ChuDeModel? chuDeHienTai;
  List<KetQuaAI> cuocHoiThoaiHienTai = [];
  KetQuaAI? ketQuaHienTai;

  ChiSoNps? chiSoNps;
  List<DiemThoiGian> danhSachDiemThoiGian = [];
  List<KetQuaAI> danhSachBinhLuan = [];
  String boLocThoiGianHienTai = '7_ngay';
  Map<String, dynamic>? adminUser;
  bool get isAdmin => adminUser != null;

  AppProvider() {
    _kiemTraDangNhapCu();
    khoiChayPhienKhach();
  }

  Future<void> khoiChayPhienKhach() async {
    try {
      String deviceId = 'unknown_device_id';
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'ios_device';
      }

      final userData = await _apiService.loginGuest(deviceId);
      if (userData != null) {
        guestUser = userData;
        notifyListeners();
        await taiDanhSachChuDe();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> taiDanhSachChuDe() async {
    if (guestUser == null) return;
    final idTaiKhoan = guestUser!['id'];
    danhSachChuDe = await _apiService.layDanhSachSidebar(idTaiKhoan);
    
    if (danhSachChuDe.isEmpty) {
      await taoChuDeMoi('Phiên phân tích khởi tạo');
    } else if (chuDeHienTai == null) {
      await chonPhienChuDe(danhSachChuDe.first);
    }
    notifyListeners();
  }

  Future<void> taoChuDeMoi(String tenChuDe) async {
    if (guestUser == null) return;
    isLoading = true;
    notifyListeners();
    
    try {
      final newTopic = await _apiService.taoChuDeMoi(guestUser!['id'], tenChuDe);
      if (newTopic != null) {
        danhSachChuDe.insert(0, newTopic);
        await chonPhienChuDe(newTopic);
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> chonPhienChuDe(ChuDeModel chuDe) async {
    chuDeHienTai = chuDe;
    ketQuaHienTai = null;
    isLoading = true;
    notifyListeners();

    try {
      cuocHoiThoaiHienTai = await _apiService.layChiTietPhienChat(chuDe.id);
    } catch (e) {
      cuocHoiThoaiHienTai = [];
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> guiBinhLuanVaPhanTich(String noiDung, {File? imageFile}) async {
    if (chuDeHienTai == null) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      String? base64Str;
      String? mimeType;
      String? fName;

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        base64Str = base64Encode(bytes);
        fName = imageFile.path.split('/').last;
        if (fName.endsWith('.png')) mimeType = 'image/png';
        if (fName.endsWith('.pdf')) mimeType = 'application/pdf';
      }

      final res = await _apiService.phanTichBinhLuan(
        noiDung: noiDung,
        idChuDe: chuDeHienTai!.id,
        imageBase64: base64Str,
        mimeType: mimeType,
        fileName: fName,
      );

      if (res != null) {
        ketQuaHienTai = res;
        cuocHoiThoaiHienTai.add(res);
        
        final idx = danhSachChuDe.indexWhere((element) => element.id == chuDeHienTai!.id);
        if (idx != -1) {
          final old = danhSachChuDe[idx];
          danhSachChuDe[idx] = ChuDeModel(
            id: old.id,
            idTaiKhoan: old.idTaiKhoan,
            tenChuDe: old.tenChuDe,
            phanQuyetAi: old.phanQuyetAi,
            tomTatAi: old.tomTatAi,
            soLuongBinhLuan: old.soLuongBinhLuan + 1,
            ngayTaoStr: old.ngayTaoStr,
          );
        }
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> kichHoatHoiChanPhien() async {
    if (chuDeHienTai == null) return;
    isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.hoiChanAI(chuDeHienTai!.id);
      if (res != null) {
        final idx = danhSachChuDe.indexWhere((element) => element.id == chuDeHienTai!.id);
        if (idx != -1) {
          final updated = ChuDeModel(
            id: chuDeHienTai!.id,
            idTaiKhoan: chuDeHienTai!.idTaiKhoan,
            tenChuDe: chuDeHienTai!.tenChuDe,
            phanQuyetAi: res['phan_quyet'] ?? 'APPROVED_NEN_MUA',
            tomTatAi: res['tom_tat'],
            soLuongBinhLuan: cuocHoiThoaiHienTai.length,
            ngayTaoStr: chuDeHienTai!.ngayTaoStr,
          );
          danhSachChuDe[idx] = updated;
          chuDeHienTai = updated;
        }
      }
    } catch (e) {
      errorMessage = 'Hội chẩn thất bại: $e';
    }
    isLoading = false;
    notifyListeners();
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

  Future<void> taiDuLieuDashboard() async {
    isLoading = true;
    errorMessage = null;
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
    } catch (_) {}
    
    isLoading = false;
    errorMessage = 'Sai tài khoản quản trị hệ thống!';
    notifyListeners();
    return false;
  }

  Future<void> dangXuatAdmin() async {
    adminUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_ho_ten');
    await prefs.remove('admin_vai_tro');
    notifyListeners();
  }
}