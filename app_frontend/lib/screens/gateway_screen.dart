import 'package:flutter/material.dart';
import '../utils/app_config.dart';
import 'public_sentiment_screen.dart';
import 'admin_login_screen.dart';

class GatewayScreen extends StatelessWidget {
  const GatewayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppConfig.darkNavy, AppConfig.lightNavy],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
                  color: AppConfig.primaryColor.withValues(alpha: 0.15),
                  border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.3), width: 2),
                ),
                child: const Icon(Icons.psychology_alt_rounded, size: 88, color: AppConfig.primaryColor),
              ),
              const SizedBox(height: 32),
              const Text('SentiFlow AI', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Text('Nền tảng phân tích cảm xúc & Hội chẩn', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
              const SizedBox(height: 64),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PublicSentimentScreen())),
                  child: const Text('BẮT ĐẦU PHÂN TÍCH (CLIENT)', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.admin_panel_settings_rounded, size: 16, color: Colors.white.withOpacity(0.6)),
                      const SizedBox(width: 8),
                      Text('Khu vực Quản trị', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}