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
  bool isLoading = false;

  void _xuLyDangNhap() async {
    setState(() => isLoading = true);
    final thanhCong = await context.read<AppProvider>().dangNhapAdmin(_usrController.text.trim(), _pwdController.text.trim());
    setState(() => isLoading = false);
    if (thanhCong && mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.darkNavy,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, size: 80, color: AppConfig.primaryColor),
            const SizedBox(height: 32),
            TextField(controller: _usrController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: AppConfig.lightNavy, hintText: 'Tài khoản admin', hintStyle: const TextStyle(color: Colors.white54), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 16),
            TextField(controller: _pwdController, obscureText: true, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: AppConfig.lightNavy, hintText: 'Mật khẩu', hintStyle: const TextStyle(color: Colors.white54), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppConfig.primaryColor, foregroundColor: AppConfig.darkNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: isLoading ? null : _xuLyDangNhap,
                child: isLoading ? const CircularProgressIndicator(color: AppConfig.darkNavy) : const Text('ĐĂNG NHẬP ADMIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}