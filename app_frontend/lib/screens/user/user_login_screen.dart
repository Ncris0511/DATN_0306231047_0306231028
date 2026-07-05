import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_config.dart';
import '../../providers/app_provider.dart';
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
    final success = await prov.dangNhapClient(
      _emailController.text.trim(),
      _pwdController.text.trim(),
    );
    if (success && mounted)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PublicSentimentScreen()),
      );
    else if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.errorMessage ?? 'Lỗi'),
          backgroundColor: AppConfig.negativeColor,
        ),
      );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.stream_rounded,
              size: 60,
              color: AppConfig.primary(isDark),
            ),
            const SizedBox(height: 24),
            Text(
              'Chào mừng trở lại,',
              style: TextStyle(
                color: AppConfig.textMain(isDark),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đăng nhập để lưu lịch sử phân tích',
              style: TextStyle(color: AppConfig.textSub(isDark), fontSize: 16),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _emailController,
              style: TextStyle(color: AppConfig.textMain(isDark)),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: AppConfig.textSub(isDark)),
                prefixIcon: Icon(
                  Icons.email_outlined,
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
            const SizedBox(height: 20),
            TextField(
              controller: _pwdController,
              obscureText: _obscureText,
              style: TextStyle(color: AppConfig.textMain(isDark)),
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                labelStyle: TextStyle(color: AppConfig.textSub(isDark)),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: AppConfig.primary(isDark),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppConfig.textSub(isDark),
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
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
                onPressed: prov.isLoading ? null : _login,
                child: prov.isLoading
                    ? CircularProgressIndicator(
                        color: AppConfig.primaryText(isDark),
                      )
                    : Text(
                        'ĐĂNG NHẬP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppConfig.primaryText(isDark),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chưa có tài khoản?',
                  style: TextStyle(color: AppConfig.textSub(isDark)),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserRegisterScreen(),
                    ),
                  ),
                  child: Text(
                    'Đăng ký ngay',
                    style: TextStyle(
                      color: AppConfig.primary(isDark),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
