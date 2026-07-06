import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_config.dart';
import '../../providers/app_provider.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  // ĐÃ XÓA CHỮ NHẬP SẴN THEO CHỈ THỊ CỦA ĐẠI TƯỚNG
  final TextEditingController _usrController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool _obscureText = true;

  void _xuLyDangNhap() async {
    if (_usrController.text.trim().isEmpty ||
        _pwdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
      );
      return;
    }

    final prov = context.read<AppProvider>();
    final thanhCong = await prov.dangNhapAdmin(
      _usrController.text.trim(),
      _pwdController.text.trim(),
    );

    if (thanhCong && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.errorMessage ?? 'Không thể truy cập!'),
          backgroundColor: AppConfig.negativeColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDarkMode;

    return Scaffold(
      backgroundColor: AppConfig.bg(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppConfig.textMain(isDark)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. LOGO & TIÊU ĐỀ
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConfig.primary(isDark).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 80,
                  color: AppConfig.primary(isDark),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "SentiFlow Admin",
                style: TextStyle(
                  color: AppConfig.textMain(isDark),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Hệ thống Giám sát & Quản trị AI",
                style: TextStyle(
                  color: AppConfig.textSub(isDark),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),

              // 2. KHỐI FORM ĐĂNG NHẬP (CARD NỔI)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppConfig.card(isDark),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppConfig.border(isDark)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _usrController,
                      style: TextStyle(color: AppConfig.textMain(isDark)),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppConfig.primary(isDark),
                        ),
                        filled: true,
                        fillColor: AppConfig.inputBg(isDark),
                        labelText: 'Email Quản trị',
                        labelStyle: TextStyle(color: AppConfig.textSub(isDark)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _pwdController,
                      obscureText: _obscureText,
                      style: TextStyle(color: AppConfig.textMain(isDark)),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: AppConfig.primary(isDark),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppConfig.textSub(isDark),
                          ),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                        filled: true,
                        fillColor: AppConfig.inputBg(isDark),
                        labelText: 'Khóa bảo mật',
                        labelStyle: TextStyle(color: AppConfig.textSub(isDark)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // NÚT TRUY CẬP CAO CẤP
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConfig.primary(isDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: prov.isLoading ? null : _xuLyDangNhap,
                        child: prov.isLoading
                            ? CircularProgressIndicator(
                                color: AppConfig.primaryText(isDark),
                              )
                            : Text(
                                'TRUY CẬP HỆ THỐNG',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppConfig.primaryText(isDark),
                                  letterSpacing: 1.0,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
