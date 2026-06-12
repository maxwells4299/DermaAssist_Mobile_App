import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/glass_morphism.dart';
import '../services/ml_service.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _blurEnabled = true;
  bool _hasPermissions = false;
  bool _isPermissionPermanentlyDenied = false;
  XFile? _uploadedImage;
  bool _isAnalyzing = false;
  final MLService _mlService = MLService();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    setState(() {
      _hasPermissions = cameraStatus.isGranted;
      _isPermissionPermanentlyDenied = cameraStatus.isPermanentlyDenied;
    });
    if (_hasPermissions) _initializeCamera();
  }

  void _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _controller = CameraController(backCamera, ResolutionPreset.medium, enableAudio: false);
      _initializeControllerFuture = _controller!.initialize();
      final prefs = await SharedPreferences.getInstance();
      setState(() => _blurEnabled = prefs.getBool('blur_enabled') ?? true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera failed to load')),
      );
    }
  }

  Future<void> _toggleBlur(bool? value) async {
    if (value == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('blur_enabled', value);
    setState(() => _blurEnabled = value);
  }

  Future<void> _takePicture() async {
    try {
      if (!_hasPermissions) {
        await _requestPermissions();
      }
      if (!_hasPermissions) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isPermissionPermanentlyDenied
                  ? 'Camera permission permanently denied.'
                  : 'Camera permission is required',
            ),
            action: _isPermissionPermanentlyDenied
                ? SnackBarAction(
                    label: 'Settings',
                    onPressed: _openSettingsAndRefreshPermission,
                  )
                : null,
          ),
        );
        return;
      }
      if (_initializeControllerFuture == null || _controller == null) return;
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      setState(() => _uploadedImage = image);
      // Removed automatic navigation
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to capture image')),
      );
    }
  }

  Future<void> _openSettingsAndRefreshPermission() async {
    await openAppSettings();
    await _requestPermissions();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _uploadedImage = image);
        // Removed automatic navigation
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load image')),
      );
    }
  }

  void _navigateToResult(MLResult result) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(result: result)));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.grey[900];
    final secondaryColor = isDark ? Colors.grey[300] : Colors.grey[600];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scan or Upload Skin Lesion', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 8),
                Text('Capture a clear image of your skin lesion for AI analysis', style: TextStyle(color: secondaryColor)),

                const SizedBox(height: 32),
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (_uploadedImage == null)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 250,
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), width: 2, style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(16),
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                              ),
                              child: Center(child: Text('Place lesion here', style: TextStyle(color: secondaryColor))),
                            ),
                            if (_controller != null && _controller!.value.isInitialized)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 250,
                                  child: CameraPreview(_controller!),
                                ),
                              ),
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: const Text('Tap buttons below to capture', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(File(_uploadedImage!.path), fit: BoxFit.cover, width: double.infinity, height: 250)
                        ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickImageFromGallery,
                              icon: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
                              label: Text('Gallery', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_uploadedImage != null) {
                                  setState(() => _uploadedImage = null);
                                } else {
                                  _takePicture();
                                }
                              },
                              icon: Icon(_uploadedImage != null ? Icons.refresh : Icons.camera_alt, color: Colors.white),
                              label: Text(_uploadedImage != null ? 'Retake' : 'Capture', style: const TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!_hasPermissions) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Camera permission is off. Gallery upload still works.',
                          style: TextStyle(color: Colors.orange[700], fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        if (_isPermissionPermanentlyDenied) ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _openSettingsAndRefreshPermission,
                            icon: const Icon(Icons.settings),
                            label: const Text('Open App Settings'),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isAnalyzing ? null : () async {
                      if (_uploadedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please capture or select an image first.')),
                        );
                      } else {
                         setState(() { _isAnalyzing = true; });
                         try {
                           final mlResult = await _mlService.runPrediction(_uploadedImage!, _blurEnabled);
                           if (!mounted) return;
                           _navigateToResult(mlResult);
                         } catch (e) {
                           if (!mounted) return;
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analysis failed. Please try again.')));
                         } finally {
                           if (mounted) setState(() { _isAnalyzing = false; });
                         }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _uploadedImage == null ? Colors.grey : Colors.green[600],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      disabledBackgroundColor: Colors.green[800],
                      shadowColor: (_uploadedImage == null ? Colors.grey : Colors.green).withValues(alpha: 0.5),
                    ),
                    child: _isAnalyzing 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('Analyze Skin Lesion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 24),
                GlassContainer(
                   padding: const EdgeInsets.all(16.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        Text('Preprocessing', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(
                           children: [
                              Text('Gaussian Blur Filters', style: TextStyle(color: primaryColor)),
                              const Spacer(),
                              Switch(
                                 value: _blurEnabled,
                                 onChanged: _toggleBlur,
                                 activeThumbColor: Theme.of(context).colorScheme.primary,
                                 activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                              ),
                           ],
                        ),
                        Text('Improves robustness to motion blur and poor focus for AI analysis.', style: TextStyle(color: secondaryColor, fontSize: 12)),
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
}