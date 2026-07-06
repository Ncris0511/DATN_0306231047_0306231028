import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_config.dart';
import '../providers/app_provider.dart';
import 'user/public_sentiment_screen.dart';
import 'user/user_login_screen.dart';
import 'admin/admin_login_screen.dart';

class GatewayScreen extends StatelessWidget {
  const GatewayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppProvider>().isDarkMode;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B)]
                : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppConfig.primary(isDark).withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppConfig.primary(isDark).withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20), // Giữ bo góc cho đẹp
                  child: Image.asset(
                    'assets/images/logo.png', // Gọi thẳng bức ảnh logo màu xanh ra
                    width: 90,
                    height: 90,
                    fit: BoxFit.contain, // Giữ nguyên tỷ lệ ảnh để không bị méo
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'SentiFlow AI',
                style: TextStyle(
                  color: AppConfig.textMain(isDark),
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppConfig.primary(isDark).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Giám định Cảm xúc Sản phẩm Đa luồng',
                  style: TextStyle(
                    color: AppConfig.primary(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primary(isDark),
                      elevation: 8,
                      shadowColor: AppConfig.primary(isDark).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserLoginScreen(),
                      ),
                    ),
                    child: Text(
                      'BẮT ĐẦU SỬ DỤNG',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.primaryText(isDark),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PublicSentimentScreen(),
                  ),
                ),
                child: Text(
                  'Trải nghiệm nhanh (Khách ẩn danh)',
                  style: TextStyle(
                    color: AppConfig.textSub(isDark),
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              TextButton.icon(
                icon: Icon(
                  Icons.admin_panel_settings,
                  color: AppConfig.textSub(isDark),
                  size: 18,
                ),
                label: Text(
                  'Khu vực Quản trị Hệ thống',
                  style: TextStyle(
                    color: AppConfig.textSub(isDark),
                    fontSize: 13,
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
