import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_config.dart';
import '../providers/app_provider.dart';
import 'public_sentiment_screen.dart';
import 'user_register_screen.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});
  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool _obscureText = true;

  void _login() async {
    final prov = context.read<AppProvider>();
    final success = await prov.dangNhapClient(_emailController.text.trim(), _pwdController.text.trim());
    if (success && mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PublicSentimentScreen()));
    else if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(prov.errorMessage ?? 'Lỗi'), backgroundColor: AppConfig.negativeColor));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppProvider>().isLoading;
    return Scaffold(
      backgroundColor: AppConfig.darkNavy,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.stream_rounded, size: 60, color: AppConfig.primaryColor),
            const SizedBox(height: 24),
            const Text('Chào mừng trở lại,', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Đăng nhập để lưu lịch sử phân tích', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16)),
            const SizedBox(height: 48),
            TextField(controller: _emailController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Email', labelStyle: const TextStyle(color: Colors.white54), prefixIcon: const Icon(Icons.email_outlined, color: AppConfig.primaryColor), filled: true, fillColor: AppConfig.lightNavy, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 20),
            TextField(controller: _pwdController, obscureText: _obscureText, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Mật khẩu', labelStyle: const TextStyle(color: Colors.white54), prefixIcon: const Icon(Icons.lock_outline, color: AppConfig.primaryColor), suffixIcon: IconButton(icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white54), onPressed: () => setState(() => _obscureText = !_obscureText)), filled: true, fillColor: AppConfig.lightNavy, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppConfig.primaryColor, foregroundColor: AppConfig.darkNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: isLoading ? null : _login,
                child: isLoading ? const CircularProgressIndicator(color: AppConfig.darkNavy) : const Text('ĐĂNG NHẬP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Chưa có tài khoản?', style: TextStyle(color: Colors.white70)),
                TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserRegisterScreen())), child: const Text('Đăng ký ngay', style: TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold)))
              ],
            )
          ],
        ),
      ),
    );
  }
}