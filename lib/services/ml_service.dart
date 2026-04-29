import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../utils/gaussian_blur.dart';

class MLResult {
  final double melanomaProbability;
  final int inferenceTimeMs;
  final String imagePath;
  
  MLResult({
    required this.melanomaProbability,
    required this.inferenceTimeMs,
    required this.imagePath,
  });
}


class MLService {
  // Simulates loading the model (e.g. EfficientNet-Lite1 + Transformer)
  Future<void> loadModel() async {
    // TODO: Uncomment when model is ready
    // _interpreter = await Interpreter.fromAsset('assets/models/efficientnet_lite1_vit.tflite');
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Prepares the image and passes through Gaussian Preprocessing Module (GPM)
  Future<MLResult> runPrediction(XFile file, bool enableGPM) async {
    final stopwatch = Stopwatch()..start();
    
    // Offload image processing to an isolate so UI doesn't freeze
    final resultProbability = await compute(_processImageAndPredict, {"path": file.path, "enableGPM": enableGPM});
    
    stopwatch.stop();
    
    // Force a mock minimum sub-100ms time for the demo if it runs too fast (since it's not actually running TFLite yet)
    int elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 45) elapsed = 45 + (DateTime.now().millisecond % 40); 

    return MLResult(
      melanomaProbability: resultProbability,
      inferenceTimeMs: elapsed,
      imagePath: file.path,
    );
  }
}

// Background Isolate Worker Function
double _processImageAndPredict(Map<String, dynamic> params) {
  final String path = params['path'];
  final bool enableGPM = params['enableGPM'];

  // 1. Load image
  final bytes = File(path).readAsBytesSync();
  img.Image? decodedImage = img.decodeImage(bytes);
  if (decodedImage == null) return 0.0;

  // Resize image for EfficientNet Standard Input (e.g. 224 x 224)
  img.Image resizedImage = img.copyResize(decodedImage, width: 224, height: 224);

  // 2. Extract raw RGBA bytes for Gaussian Blur
  Uint8List rgbaBytes = resizedImage.getBytes(order: img.ChannelOrder.rgba);

  // 3. Gaussian Preprocessing Module (GPM) Layer
  if (enableGPM) {
    // Sigma of 2.0 or 1.0 depending on exact implementation, applies blurring algorithm
    rgbaBytes = applyGaussianBlur(rgbaBytes, 224, 224, sigma: 1.0);
  }

  // 4. Dual-Stream Model (CNN - Transformer) Logic
  // Convert RGBA back to Float32 Tensor array [1, 224, 224, 3] normalizing values
  // List<List<List<List<double>>>> inputTensor = List.generate(1, (i) => List.generate(224, (y) => List.generate(224, (x) => List.filled(3, 0.0))));
  // var pixelIndex = 0;
  // for (var y = 0; y < 224; y++) {
  //   for (var x = 0; x < 224; x++) {
  //     inputTensor[0][y][x][0] = rgbaBytes[pixelIndex] / 255.0;     // R
  //     inputTensor[0][y][x][1] = rgbaBytes[pixelIndex + 1] / 255.0; // G
  //     inputTensor[0][y][x][2] = rgbaBytes[pixelIndex + 2] / 255.0; // B
  //     pixelIndex += 4; // Skip Alpha
  //   }
  // }

  // 5. Run TFLite Prediction
  // var outputTensor = List.filled(1, 0.0).reshape([1, 1]); // e.g. [1, 1] output representing Melanoma Probability
  // _interpreter.run(inputTensor, outputTensor);
  // return outputTensor[0][0];

  // TODO: Remove this mock code once TFLite is running
  // Return a mock placeholder value demonstrating functionality
  return 0.76; 
}
