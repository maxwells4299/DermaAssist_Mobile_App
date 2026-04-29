import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final imagePath = 'assets/images/app_icon.png';
  final bytes = File(imagePath).readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return;
  
  // Using 20% of smallest dimension as radius
  int radius = (image.width < image.height ? image.width : image.height) ~/ 5;
  
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      // Top-Left
      if (x < radius && y < radius) {
        if ((radius - x)*(radius - x) + (radius - y)*(radius - y) > radius*radius) {
          image.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
        }
      }
      // Top-Right
      if (x > image.width - radius && y < radius) {
        int dx = x - (image.width - radius);
        int dy = radius - y;
        if (dx*dx + dy*dy > radius*radius) {
          image.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
        }
      }
      // Bottom-Left
      if (x < radius && y > image.height - radius) {
        int dx = radius - x;
        int dy = y - (image.height - radius);
        if (dx*dx + dy*dy > radius*radius) {
          image.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
        }
      }
      // Bottom-Right
      if (x > image.width - radius && y > image.height - radius) {
        int dx = x - (image.width - radius);
        int dy = y - (image.height - radius);
        if (dx*dx + dy*dy > radius*radius) {
          image.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
        }
      }
    }
  }
  
  File(imagePath).writeAsBytesSync(img.encodePng(image));
  print('Image corners rounded successfully!');
}
