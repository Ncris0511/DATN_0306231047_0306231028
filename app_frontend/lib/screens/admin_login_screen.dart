import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_config.dart';
import '../providers/app_provider.dart';
import 'admin_dashboard_screen.dart'; // Phòng Tổng chỉ huy sẽ xây ngay sau đây!

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  // Điền sẵn mồi chuẩn CSDL để test cho lẹ, khi nộp cô chấm thì xóa text bên trong đi là xong:
  final TextEditingController _usrController = TextEditingController(
    text: 'admin_sentiflow',
  );
  final TextEditingController _pwdController = TextEditingController(
    text: '123456',
  );
  bool _hienMatKhau = false;

  @override
  void dispose() {
    _usrController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  void _xuLyDangNhap() async {
    FocusScope.of(context).unfocus(); // Rút bàn phím xuống
    final appProvider = context.read<AppProvider>();

    final thanhCong = await appProvider.dangNhapAdmin(
      _usrController.text.trim(),
      _pwdController.text.trim(),
    );

    if (!mounted) return;

    if (thanhCong) {
      // ⚠️ KỸ THUẬT BÓP CHẾT NÚT BACK VẬT LÝ:
      // Đẩy user vào Dashboard và dọn sạch sành sanh các trang Login/Gateway trước đó khỏi RAM.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  appProvider.errorMessage ??
                      'Sai tên đăng nhập hoặc mật khẩu!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppProvider>().isLoading;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppConfig.darkNavy, AppConfig.lightNavy],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nút Back lùi về Gateway:
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Biểu tượng Khiên bảo mật:
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withOpacity(0.12),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 76,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'PORTAL QUẢN TRỊ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Xác thực danh tính để vào hệ thống kiểm duyệt',
                    style: TextStyle(fontSize: 13, color: Colors.white60),
                  ),
                  const SizedBox(height: 48),

                  // Form Input 1: Username
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TextField(
                      controller: _usrController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.person_outline,
                          color: AppConfig.primaryColor.withOpacity(0.9),
                          size: 22,
                        ),
                        border: InputBorder.none,
                        labelText: 'Tên đăng nhập',
                        labelStyle: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form Input 2: Password
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TextField(
                      controller: _pwdController,
                      obscureText: !_hienMatKhau,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.lock_outline,
                          color: AppConfig.primaryColor.withOpacity(0.9),
                          size: 22,
                        ),
                        border: InputBorder.none,
                        labelText: 'Mật khẩu bảo mật',
                        labelStyle: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _hienMatKhau
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white54,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _hienMatKhau = !_hienMatKhau),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Nút Bấm Đăng Nhập:
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _xuLyDangNhap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                        elevation: 8,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'XÁC THỰC VÀO PORTAL',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
