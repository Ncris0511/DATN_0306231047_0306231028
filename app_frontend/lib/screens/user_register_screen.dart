import 'package:flutter/material.dart';
import '../utils/app_config.dart';
import '../services/api_service.dart';
import 'user_login_screen.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});
  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pwdController = TextEditingController();
  bool isLoading = false;

  void _register() async {
    final hoTen = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pwd = _pwdController.text.trim();

    // 1. Kiểm tra không được bỏ trống
    if (hoTen.isEmpty || email.isEmpty || pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!'), backgroundColor: AppConfig.negativeColor)
      );
      return;
    }

    setState(() => isLoading = true);
    final success = await ApiService().registerClient(hoTen, email, pwd);
    setState(() => isLoading = false);
    
    if (success && mounted) {
      // 2. Hiển thị Dialog chúc mừng chuyên nghiệp
      showDialog(
        context: context,
        barrierDismissible: false, // Bắt buộc phải bấm nút mới tắt được
        builder: (ctx) => AlertDialog(
          backgroundColor: AppConfig.lightNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Column(
            children: [
              Icon(Icons.check_circle_outline, color: AppConfig.positiveColor, size: 64),
              SizedBox(height: 16),
              Text('Đăng ký thành công!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
            ],
          ),
          content: const Text(
            'Tài khoản của bạn đã được tạo. Hãy đăng nhập để bắt đầu phân tích cùng SentiFlow AI.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primaryColor, 
                foregroundColor: AppConfig.darkNavy, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)
              ),
              onPressed: () {
                Navigator.pop(ctx); // Đóng Dialog
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserLoginScreen())); // Chuyển sang Đăng nhập
              },
              child: const Text('ĐĂNG NHẬP NGAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      );
    } else if (mounted) {
      // 3. Thông báo nếu email đã tồn tại hoặc lỗi server
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thất bại. Email có thể đã tồn tại!'), backgroundColor: AppConfig.negativeColor)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.darkNavy,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tạo tài khoản', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tham gia cùng SentiFlow AI ngay hôm nay.', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16)),
            const SizedBox(height: 48),
            
            TextField(controller: _nameController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Họ và Tên', labelStyle: const TextStyle(color: Colors.white54), prefixIcon: const Icon(Icons.person_outline, color: AppConfig.primaryColor), filled: true, fillColor: AppConfig.lightNavy, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 20),
            
            TextField(controller: _emailController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Email', labelStyle: const TextStyle(color: Colors.white54), prefixIcon: const Icon(Icons.email_outlined, color: AppConfig.primaryColor), filled: true, fillColor: AppConfig.lightNavy, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 20),
            
            TextField(controller: _pwdController, obscureText: true, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Mật khẩu', labelStyle: const TextStyle(color: Colors.white54), prefixIcon: const Icon(Icons.lock_outline, color: AppConfig.primaryColor), filled: true, fillColor: AppConfig.lightNavy, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppConfig.primaryColor, foregroundColor: AppConfig.darkNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: isLoading ? null : _register,
                child: isLoading ? const CircularProgressIndicator(color: AppConfig.darkNavy) : const Text('ĐĂNG KÝ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Đã có tài khoản?', style: TextStyle(color: Colors.white70)),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserLoginScreen())), 
                  child: const Text('Đăng nhập', style: TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold, fontSize: 15))
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}