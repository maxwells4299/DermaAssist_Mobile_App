import 'dart:typed_data';
import 'dart:math' as math;

List<double> _createGaussianKernel(double sigma) {
  final size = (math.max(1, (sigma * 3).ceil()) * 2 + 1);
  final half = size ~/ 2;
  final kernel = List<double>.filled(size, 0.0);
  double sum = 0.0;

  for (int i = 0; i < size; i++) {
    final x = i - half;
    kernel[i] = math.exp(-(x * x) / (2 * sigma * sigma));
    sum += kernel[i];
  }

  for (int i = 0; i < size; i++) {
    kernel[i] /= sum;
  }

  return kernel;
}

Uint8List applyGaussianBlur(Uint8List src, int width, int height, {double sigma = 1.0}) {
  final kernel = _createGaussianKernel(sigma);
  final half = kernel.length ~/ 2;
  final dst = Uint8List(src.length);

  for (int channel = 0; channel < 4; channel++) {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double acc = 0.0;
        for (int k = 0; k < kernel.length; k++) {
          final xi = (x + k - half).clamp(0, width - 1);
          final idx = (y * width + xi) * 4 + channel;
          acc += src[idx] * kernel[k];
        }
        dst[y * width * 4 + x * 4 + channel] = acc.toInt().clamp(0, 255);
      }
    }
  }

  return dst;
}