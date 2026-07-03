import 'package:flutter/material.dart';
import '../utils/app_config.dart';
import 'public_sentiment_screen.dart';
import 'user_login_screen.dart';
import 'admin_login_screen.dart';

class GatewayScreen extends StatelessWidget {
  const GatewayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.darkNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology_alt_rounded, size: 100, color: AppConfig.primaryColor),
            const SizedBox(height: 24),
            const Text('SentiFlow AI', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text('Gemini-powered Sentiment Analysis', style: TextStyle(color: AppConfig.primaryColor.withValues(alpha: 0.8), fontSize: 14)),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppConfig.primaryColor, foregroundColor: AppConfig.darkNavy, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserLoginScreen())),
              child: const Text('ĐĂNG NHẬP / ĐĂNG KÝ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PublicSentimentScreen())),
              child: const Text('Trải nghiệm ẩn danh (Guest)', style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline)),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.white54), label: const Text('Khu vực Quản trị', style: TextStyle(color: Colors.white54)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
            )
          ],
        ),
      ),
    );
  }
}