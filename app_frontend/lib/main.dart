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
        primaryColor: AppConfig.primaryColor,
        scaffoldBackgroundColor: AppConfig.darkNavy,
        fontFamily: 'Roboto',
        useMaterial3: true,
        textSelectionTheme: const TextSelectionThemeData(cursorColor: AppConfig.primaryColor),
      ),
      home: const GatewayScreen(),
    );
  }
}