import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'utils/app_config.dart';
import 'screens/gateway_screen.dart';
import 'screens/user/public_sentiment_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

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
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDarkMode;

    // [ĐÃ NÂNG CẤP]: MÀN HÌNH CHỜ KIỂM TRA ĐĂNG NHẬP
    Widget initialScreen;
    if (!prov.isInitDone) {
      initialScreen = Scaffold(
        backgroundColor: AppConfig.bg(isDark),
        body: Center(
          child: CircularProgressIndicator(color: AppConfig.primary(isDark)),
        ),
      );
    } else if (prov.isAdmin) {
      initialScreen = const AdminDashboardScreen();
    } else if (prov.isLoggedUser) {
      initialScreen = const PublicSentimentScreen();
    } else {
      initialScreen = const GatewayScreen();
    }

    return MaterialApp(
      title: 'SentiFlow AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        primaryColor: AppConfig.primary(isDark),
        scaffoldBackgroundColor: AppConfig.bg(isDark),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConfig.primary(isDark),
          brightness: isDark ? Brightness.dark : Brightness.light,
          surface: AppConfig.card(isDark),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppConfig.textMain(isDark)),
          bodyMedium: TextStyle(color: AppConfig.textMain(isDark)),
          titleLarge: TextStyle(
            color: AppConfig.textMain(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: initialScreen, // Tự động nhận diện màn hình
    );
  }
}
