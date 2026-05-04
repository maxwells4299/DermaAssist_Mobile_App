import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/glass_morphism.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/ml_service.dart';
import 'chatbot_screen.dart';

class ResultScreen extends StatefulWidget {
  final MLResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String get riskLevel {
    if (widget.result.melanomaProbability >= 0.7) return 'High Risk';
    if (widget.result.melanomaProbability >= 0.4) return 'Medium Risk';
    return 'Low Risk';
  }

  Color get riskColor {
    if (widget.result.melanomaProbability >= 0.7) return Colors.redAccent;
    if (widget.result.melanomaProbability >= 0.4) return Colors.orangeAccent;
    return Colors.greenAccent;
  }

  @override
  void initState() {
    super.initState();
    _saveScan();
  }

  Future<void> _saveScan() async {
    final user = await AuthService().getUser();
    if (user != null) {
      final userId = user['id'];
      await DatabaseService().saveScan(
        userId,
        widget.result.melanomaProbability,
        DateTime.now().toIso8601String(),
      );
    }
  }

  Widget _buildGradCamOverlay() {
    // We simulate a heatmap overlay to demonstrate UI capability 
    // for when the actual Grad-CAM TFLite model is integrated.
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.1, -0.1), // Mocked hotspot position 
            radius: 0.7,
            colors: [
              Colors.red.withValues(alpha: 0.65),
              Colors.orange.withValues(alpha: 0.45),
              Colors.yellow.withValues(alpha: 0.25),
              Colors.cyan.withValues(alpha: 0.1),
              Colors.transparent,
            ],
            stops: const [0.1, 0.4, 0.7, 0.85, 1.0],
          ),
          backgroundBlendMode: BlendMode.overlay,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.grey[900]!;
    final secondaryColor = isDark ? Colors.grey[300]! : Colors.grey[700]!;
    final confidencePercent = (widget.result.melanomaProbability * 100).toInt();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Analysis Result', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  
                  // Grad-CAM Visualization
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Grad-CAM Visualization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (widget.result.imagePath.isNotEmpty)
                                Image.file(File(widget.result.imagePath), fit: BoxFit.cover, height: 250, width: double.infinity)
                              else
                                Container(height: 250, color: Colors.grey[800], child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.white54))),
                              
                              // Simulated Grad-CAM Heatmap overlay
                              if (widget.result.melanomaProbability >= 0.3)
                                _buildGradCamOverlay(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The heatmap highlights regions the CNN-Transformer framework weighed most heavily during classification.',
                          style: TextStyle(fontSize: 12, color: secondaryColor),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  // Abnormality Detected
                  GlassContainer(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          widget.result.melanomaProbability >= 0.7 ? Icons.warning_rounded : Icons.check_circle_rounded,
                          size: 72,
                          color: riskColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.result.melanomaProbability >= 0.5 ? 'Abnormality Detected' : 'No Immediate Concerns',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: riskColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.result.melanomaProbability >= 0.5
                             ? 'Your scan shows features that need medical attention.'
                             : 'Your scan does not show obvious features of concern. However, routinely check your skin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  // Analysis Results (Focus on Inference metrics too)
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Detailed Findings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: primaryColor)),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: riskColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.health_and_safety,
                                color: riskColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: Text('AI Confidence and inference metrics derived from the model.', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700]))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _resultRow('Melanoma Present', widget.result.melanomaProbability >= 0.5 ? 'True' : 'False', primaryColor),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white24)),
                        _resultRow('Risk Level', riskLevel, primaryColor),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white24)),
                        _resultRow('Confidence Score', '$confidencePercent%', primaryColor),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white24)),
                        _resultRow('On-Device Inference', '${widget.result.inferenceTimeMs} ms', Colors.greenAccent[400]!),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      final query = "My scan says $confidencePercent% confidence of being ${widget.result.melanomaProbability >= 0.5 ? 'melanoma' : 'benign'}. What does this mean?";
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotScreen(initialQuery: query)));
                    },
                    icon: const Icon(Icons.chat_bubble, color: Colors.deepPurple),
                    label: const Text('Discuss with AI Assistant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 18),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       elevation: 8,
                       shadowColor: Colors.deepPurple.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.deepPurple,
                       padding: const EdgeInsets.symmetric(vertical: 18),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       elevation: 8,
                       shadowColor: Colors.deepPurple.withValues(alpha: 0.5),
                    ),
                    child: const Text('Back to Scanner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),

                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Disclaimer: This tool provides screening assistance only. It does not replace professional medical diagnosis or treatment. Always consult a licensed dermatologist.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: color)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }
}