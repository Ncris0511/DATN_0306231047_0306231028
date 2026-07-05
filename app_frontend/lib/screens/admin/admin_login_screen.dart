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
  final TextEditingController _usrController = TextEditingController(
    text: 'admin_sentiflow',
  );
  final TextEditingController _pwdController = TextEditingController(
    text: '123456',
  );

  void _xuLyDangNhap() async {
    final prov = context.read<AppProvider>();
    final thanhCong = await prov.dangNhapAdmin(
      _usrController.text.trim(),
      _pwdController.text.trim(),
    );
    if (thanhCong && mounted) {
      // Dùng pushReplacement để xóa nút Quay Về
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield, size: 80, color: AppConfig.primary(isDark)),
            const SizedBox(height: 32),
            TextField(
              controller: _usrController,
              style: TextStyle(color: AppConfig.textMain(isDark)),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppConfig.inputBg(isDark),
                hintText: 'Tài khoản admin',
                hintStyle: TextStyle(color: AppConfig.textSub(isDark)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pwdController,
              obscureText: true,
              style: TextStyle(color: AppConfig.textMain(isDark)),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppConfig.inputBg(isDark),
                hintText: 'Mật khẩu',
                hintStyle: TextStyle(color: AppConfig.textSub(isDark)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primary(isDark),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: prov.isLoading ? null : _xuLyDangNhap,
                child: prov.isLoading
                    ? CircularProgressIndicator(
                        color: AppConfig.primaryText(isDark),
                      )
                    : Text(
                        'ĐĂNG NHẬP ADMIN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppConfig.primaryText(isDark),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
