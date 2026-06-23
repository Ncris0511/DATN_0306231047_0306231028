import 'dart:io'; // <--- Nạp thư viện rà soát OS vật lý
import 'package:flutter/material.dart';

class AppConfig {
  // ⚠️ TỰ ĐỘNG PHÂN GIẢI CỔNG MẠNG THEO THIẾT BỊ:
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api'; // Đường hầm xuyên qua đĩa Mac cho Android ảo
    }
    return 'http://localhost:3000/api'; // Cổng mặc định cho iOS Simulator / Web / Mac
  }

  // UI Palette[cite: 1, 6]
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color darkNavy = Color(0xFF0D1B2A);
  static const Color lightNavy = Color(0xFF1B263B);
  static const Color bgCard = Color(0xFFFFFFFF);

  // Sentiment Palette[cite: 1, 6]
  static const Color positiveColor = Color(0xFF2E7D32);
  static const Color negativeColor = Color(0xFFC62828);
  static const Color neutralColor = Color(0xFFEF6C00);
}
