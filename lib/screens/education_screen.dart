import 'package:flutter/material.dart';
import '../utils/glass_morphism.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

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
                Text('Education Hub', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 8),
                Text('Learn about skin health and melanoma prevention', style: TextStyle(color: secondaryColor)),
                const SizedBox(height: 32),

                // ABCDEs Section
                Text('The ABCDEs of Melanoma', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'A is for Asymmetry',
                  content: 'One half of the mole or spot does not match the other half.',
                  icon: Icons.flip,
                  color: Colors.orangeAccent,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  title: 'B is for Border',
                  content: 'The edges are irregular, ragged, notched, or blurred.',
                  icon: Icons.border_outer,
                  color: Colors.lightBlueAccent,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  title: 'C is for Color',
                  content: 'The color is not the same all over and may include shades of brown or black, or sometimes with patches of pink, red, white, or blue.',
                  icon: Icons.color_lens,
                  color: Colors.purpleAccent,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  title: 'D is for Diameter',
                  content: 'The spot is larger than 6 millimeters across (about the size of a pencil eraser), although melanomas can sometimes be smaller.',
                  icon: Icons.straighten,
                  color: Colors.greenAccent,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  title: 'E is for Evolving',
                  content: 'The mole is changing in size, shape, or color.',
                  icon: Icons.change_circle,
                  color: Colors.redAccent,
                ),

                const SizedBox(height: 32),
                
                // Sun Safety Section
                Text('Daily Sun Safety', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 16),
                GlassContainer(
                   padding: const EdgeInsets.all(20),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        Row(
                          children: [
                            const Icon(Icons.wb_sunny, color: Colors.orange, size: 28),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Protect Your Skin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSafetyBullet('Apply a broad-spectrum sunscreen with an SPF of 30 or higher.', secondaryColor!),
                        const SizedBox(height: 8),
                        _buildSafetyBullet('Seek shade, especially during midday hours (10 AM to 4 PM).', secondaryColor),
                        const SizedBox(height: 8),
                        _buildSafetyBullet('Wear protective clothing, such as long sleeves and wide-brimmed hats.', secondaryColor),
                     ],
                   ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content, required IconData icon, required Color color}) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyBullet(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0, right: 8.0),
          child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.deepPurpleAccent, shape: BoxShape.circle)),
        ),
        Expanded(child: Text(text, style: TextStyle(color: color, height: 1.4))),
      ],
    );
  }
}
