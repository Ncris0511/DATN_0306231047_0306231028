import 'dart:io';
import 'package:flutter/material.dart';

class AppConfig {
  static String get baseUrl => Platform.isAndroid ? 'http://10.0.2.2:3000/api' : 'http://localhost:3000/api';

  // Theme Phong cách Gemini AI (Dark Theme Cao Cấp)
  static const Color primaryColor = Color(0xFFA8C7FA); 
  static const Color darkNavy = Color(0xFF131314);     
  static const Color lightNavy = Color(0xFF1E1F22);    
  static const Color bgCard = Color(0xFF131314);       
  
  static const Color positiveColor = Color(0xFF81C995); 
  static const Color negativeColor = Color(0xFFF28B82); 
  static const Color neutralColor = Color(0xFFFDE293);  
}