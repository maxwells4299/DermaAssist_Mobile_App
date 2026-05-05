import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'history_screen.dart';
import 'education_screen.dart';
import 'chatbot_screen.dart';
import 'settings_screen.dart';
import 'onboarding_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ScanScreen(),
    const HistoryScreen(),
    const EducationScreen(),
    const ChatbotScreen(),
    const SettingsScreen(),
  ];

  String _getTitle() {
    switch (_currentIndex) {
      case 0: return 'MelanomaScan';
      case 1: return 'History';
      case 2: return 'Education';
      case 3: return 'AI Assistant';
      case 4: return 'Settings';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_getTitle(), style: TextStyle(color: isDark ? Colors.white : Colors.grey[900], fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.primary),
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()), (route) => false);
              }
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Set to fixed to show 5 items properly
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Education'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'AI Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
      ),
    );
  }
}