import 'dart:io';
import 'package:flutter/material.dart';

class AppConfig {
  static String get baseUrl => Platform.isAndroid
      ? 'http://10.0.2.2:3000/api'
      : 'http://localhost:3000/api';

  static Color primary(bool isDark) =>
      isDark ? const Color(0xFFA8C7FA) : const Color(0xFF2563EB);
  static Color primaryText(bool isDark) =>
      isDark ? const Color(0xFF131314) : Colors.white;

  static Color bg(bool isDark) =>
      isDark ? const Color(0xFF131314) : const Color(0xFFF8FAFC);
  static Color card(bool isDark) =>
      isDark ? const Color(0xFF1E1F22) : Colors.white;
  static Color inputBg(bool isDark) =>
      isDark ? const Color(0xFF131314) : const Color(0xFFF1F5F9);

  static Color textMain(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF1E293B);
  static Color textSub(bool isDark) =>
      isDark ? Colors.white70 : const Color(0xFF64748B);
  static Color border(bool isDark) =>
      isDark ? Colors.white10 : Colors.grey.shade300;

  static const Color positiveColor = Color(0xFF10B981);
  static const Color negativeColor = Color(0xFFEF4444);
  static const Color neutralColor = Color(0xFFF59E0B);
}
