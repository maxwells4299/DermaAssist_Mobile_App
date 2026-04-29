import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../utils/glass_morphism.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.grey[900];
    final secondaryColor = isDark ? Colors.grey[300] : Colors.grey[700];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile & Settings', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 32),

                // Medical Profile Mock
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.deepPurpleAccent, size: 28),
                          const SizedBox(width: 12),
                          Text('Medical Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildProfileRow('Age', '45', secondaryColor, primaryColor),
                      const Divider(color: Colors.white24, height: 24),
                      _buildProfileRow('Skin Type', 'Fitzpatrick Type II', secondaryColor, primaryColor),
                      const Divider(color: Colors.white24, height: 24),
                      _buildProfileRow('Family History', 'None', secondaryColor, primaryColor),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // App Preferences
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.settings, color: Colors.deepPurpleAccent, size: 28),
                          const SizedBox(width: 12),
                          Text('App Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Dark Theme', style: TextStyle(fontSize: 16, color: primaryColor, fontWeight: FontWeight.w500)),
                          Switch(
                            value: isDark,
                            onChanged: (value) {
                              final theme = Provider.of<ThemeService>(context, listen: false);
                              theme.save(value ? ThemeMode.dark : ThemeMode.light);
                            },
                            activeColor: Colors.deepPurpleAccent,
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Notifications', style: TextStyle(fontSize: 16, color: primaryColor, fontWeight: FontWeight.w500)),
                          Switch(
                            value: true,
                            onChanged: (value) {},
                            activeColor: Colors.deepPurpleAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await AuthService().logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()), (route) => false);
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.redAccent, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, Color? labelColor, Color? valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 15)),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w600, fontSize: 15)),
      ],
    );
  }
}
