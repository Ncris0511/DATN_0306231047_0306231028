import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_config.dart';
import '../providers/app_provider.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _usrController = TextEditingController(text: 'admin_sentiflow');
  final TextEditingController _pwdController = TextEditingController(text: '123456');
  bool _hienMatKhau = false;
  bool isLoading = false;

  @override
  void dispose() {
    _usrController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  void _xuLyDangNhap() async {
    FocusScope.of(context).unfocus();
    final appProvider = context.read<AppProvider>();

    setState(() => isLoading = true);
    final thanhCong = await appProvider.dangNhapAdmin(
      _usrController.text.trim(),
      _pwdController.text.trim(),
    );
    setState(() => isLoading = false);

    if (thanhCong) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appProvider.errorMessage ?? 'Đăng nhập thất bại!'), backgroundColor: AppConfig.negativeColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.lightNavy,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.admin_panel_settings, size: 64, color: AppConfig.darkNavy),
                  const SizedBox(height: 16),
                  const Text('QUẢN TRỊ HỆ THỐNG', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConfig.darkNavy)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _usrController,
                    decoration: InputDecoration(labelText: 'Tên đăng nhập', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pwdController,
                    obscureText: !_hienMatKhau,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_hienMatKhau ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _hienMatKhau = !_hienMatKhau),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _xuLyDangNhap,
                      style: ElevatedButton.styleFrom(backgroundColor: AppConfig.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('XÁC THỰC VÀO PORTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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