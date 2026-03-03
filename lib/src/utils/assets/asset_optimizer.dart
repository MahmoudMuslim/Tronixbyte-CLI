import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> optimizeProjectAssets() async {
  printSection('Smart Asset Optimizer');

  final assetsDir = Directory('assets');
  if (!assetsDir.existsSync()) {
    printInfo('No assets directory found.');
    return;
  }

  final images = assetsDir.listSync(recursive: true).whereType<File>().where((
    f,
  ) {
    final ext = p.extension(f.path).toLowerCase();
    return ['.png', '.jpg', '.jpeg'].contains(ext);
  }).toList();

  if (images.isEmpty) {
    printSuccess('No PNG or JPG images found to optimize.');
    return;
  }

  printInfo('Found ${images.length} images. Starting size optimization...');

  int optimizedCount = 0;
  int totalSaved = 0;

  await loadingSpinner('Optimizing assets', () async {
    for (final imageFile in images) {
      final Uint8List bytes = imageFile.readAsBytesSync();
      final int originalSize = bytes.length;

      final img.Image? image = img.decodeImage(bytes);
      if (image == null) continue;

      Uint8List optimizedBytes;
      final ext = p.extension(imageFile.path).toLowerCase();

      if (ext == '.jpg' || ext == '.jpeg') {
        // Optimize JPG by re-encoding with quality 80
        optimizedBytes = img.encodeJpg(image, quality: 80);
      } else {
        // Optimize PNG by re-encoding with max compression (level 9)
        optimizedBytes = img.encodePng(image, level: 9);
      }

      final int newSize = optimizedBytes.length;

      if (newSize < originalSize) {
        imageFile.writeAsBytesSync(optimizedBytes);
        optimizedCount++;
        totalSaved += (originalSize - newSize);
        printInfo(
          'Optimized: ${p.basename(imageFile.path)} (${(originalSize / 1024).toStringAsFixed(1)}KB -> ${(newSize / 1024).toStringAsFixed(1)}KB)',
        );
      }
    }
  });

  if (optimizedCount > 0) {
    printSuccess('Optimization complete!');
    printSuccess('Total images optimized: $optimizedCount');
    printSuccess(
      'Total storage saved: ${(totalSaved / 1024).toStringAsFixed(1)} KB',
    );
  } else {
    printInfo('All images are already highly compressed.');
  }
}
