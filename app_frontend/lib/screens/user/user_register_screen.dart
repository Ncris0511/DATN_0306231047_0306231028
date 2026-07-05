import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_config.dart';
import '../../services/api_service.dart';
import '../../providers/app_provider.dart';
import 'user_login_screen.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});
  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pwdController = TextEditingController();
  bool isLoading = false;

  void _register(bool isDark) async {
    final hoTen = _nameController.text.trim();
    final email = _emailController.text.trim();
    final sdt = _phoneController.text.trim();
    final pwd = _pwdController.text.trim();

    if (hoTen.isEmpty || email.isEmpty || sdt.isEmpty || pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
      );
      return;
    }

    setState(() => isLoading = true);

    // [ĐÃ SỬA]: Lấy lại deviceId để chuyển lịch sử từ Khách -> User
    final deviceId = context.read<AppProvider>().deviceIdMacDinh;
    final success = await ApiService().registerClient(
      hoTen,
      email,
      sdt,
      pwd,
      deviceId,
    );

    setState(() => isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công! Hãy đăng nhập để lưu trữ.'),
          backgroundColor: AppConfig.positiveColor,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserLoginScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email hoặc SĐT đã tồn tại!'),
          backgroundColor: AppConfig.negativeColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: AppConfig.bg(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppConfig.textMain(isDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tạo tài khoản',
              style: TextStyle(
                color: AppConfig.textMain(isDark),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Điền thông tin để đồng bộ dữ liệu đám mây.',
              style: TextStyle(color: AppConfig.textSub(isDark), fontSize: 16),
            ),
            const SizedBox(height: 40),

            TextField(
              controller: _nameController,
              style: TextStyle(color: AppConfig.textMain(isDark)),
              decoration: InputDecoration(
                labelText: 'Họ và Tên',
                prefixIcon: Icon(
                  Icons.person,
                  color: AppConfig.primary(isDark),
                ),
                filled: true,
                fillColor: AppConfig.inputBg(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: AppConfig.textMain(isDark)),
              decoration: InputDecoration(
                labelText: 'Địa chỉ Email',
                prefixIcon: Icon(Icons.email, color: AppConfig.primary(isDark)),
                filled: true,
                fillColor: AppConfig.inputBg(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: AppConfig.textMain(isDark)),
              decoration: InputDecoration(
                labelText: 'Số điện thoại liên hệ',
                prefixIcon: Icon(Icons.phone, color: AppConfig.primary(isDark)),
                filled: true,
                fillColor: AppConfig.inputBg(isDark),
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
                labelText: 'Mật khẩu',
                prefixIcon: Icon(Icons.lock, color: AppConfig.primary(isDark)),
                filled: true,
                fillColor: AppConfig.inputBg(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),

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
                onPressed: isLoading ? null : () => _register(isDark),
                child: isLoading
                    ? CircularProgressIndicator(
                        color: AppConfig.primaryText(isDark),
                      )
                    : Text(
                        'ĐĂNG KÝ NGAY',
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
