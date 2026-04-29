import 'package:flutter/material.dart';
import '../utils/glass_morphism.dart';
import 'sign_up_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.analytics, size: 60, color: Colors.deepPurpleAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Understand Your Symptoms',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[800]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Learn about common signs of melanoma and when to seek medical attention.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 16),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ABCDE Rule',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: isDark ? Colors.white : Colors.black87)),
                          const SizedBox(height: 8),
                          Text(
                              'Asymmetry, Border, Color, Diameter, Evolving — key signs of melanoma.',
                              style: TextStyle(
                                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                                  fontSize: 14)),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _symptomCard('A', 'Asymmetry', context),
                              const SizedBox(width: 12),
                              _symptomCard('B', 'Border', context),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _symptomCard('C', 'Color', context),
                              const SizedBox(width: 12),
                              _symptomCard('D', 'Diameter', context),
                            ],
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SignUpScreen())),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 8,
                                shadowColor: Colors.deepPurple.withValues(alpha: 0.5),
                              ),
                              child: const Text('Continue to Sign Up',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () {},
                        child: Text('Terms',
                            style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600]))),
                    Text('•',
                        style: TextStyle(
                            color: isDark ? Colors.grey[600] : Colors.grey[400])),
                    TextButton(
                        onPressed: () {},
                        child: Text('Privacy',
                            style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600]))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _symptomCard(String letter, String title, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.deepPurple.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? Colors.white12 : Colors.deepPurple.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(letter,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple)),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }
}