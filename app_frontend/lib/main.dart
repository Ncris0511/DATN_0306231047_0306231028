import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'utils/app_config.dart';
import 'screens/gateway_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppProvider())],
      child: const SentiFlowApp(),
    ),
  );
}

class SentiFlowApp extends StatelessWidget {
  const SentiFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SentiFlow AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Trỏ vào class AppConfig trong file app_config.dart của bạn:
        primaryColor: AppConfig.primaryColor,
        scaffoldBackgroundColor: AppConfig.bgCard,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const GatewayScreen(),
    );
  }
}
