import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/theme_service.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeService = ThemeService();
  final initialTheme = await themeService.getTheme();
  runApp(MelanomaApp(themeService: themeService, initialTheme: initialTheme));
}


class MelanomaApp extends StatelessWidget {
  final ThemeService themeService;
  final ThemeMode initialTheme;

  const MelanomaApp({super.key, required this.themeService, required this.initialTheme});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeService>.value(
      value: themeService,
      child: Builder(
        builder: (context) {
          final themeProvider = Provider.of<ThemeService>(context);
          return MaterialApp(
            title: 'MelanomaScan',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              fontFamily: GoogleFonts.inter().fontFamily,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2563EB),
                primary: const Color(0xFF2563EB),
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              fontFamily: GoogleFonts.inter().fontFamily,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF60A5FA),
                primary: const Color(0xFF60A5FA),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: themeProvider.currentTheme,
            home: FutureBuilder(
              future: AuthService().getUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return const HomeScreen();
                }
                return const SplashScreen();
              },
            ),
          );
        },
      ),
    );
  }
}