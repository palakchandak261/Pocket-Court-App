import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'screens/auth/login_screen.dart';
import 'main_navigation.dart';
import 'theme/app_theme.dart';

final themeService = ThemeService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  runApp(const PocketCourtApp());
}

class PocketCourtApp extends StatefulWidget {
  const PocketCourtApp({super.key});

  @override
  State<PocketCourtApp> createState() => _PocketCourtAppState();
}

class _PocketCourtAppState extends State<PocketCourtApp> {
  @override
  void initState() {
    super.initState();
    themeService.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Court',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      home:
          AuthService.isLoggedIn ? const MainNavigation() : const LoginScreen(),
    );
  }
}
