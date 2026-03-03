import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runPerformanceAssetBundling() async {
  printSection('📈 Performance-Driven Asset Bundling');

  final activePath = getActiveProjectPath();
  final assetsDir = Directory(p.join(activePath, 'assets', 'images'));

  if (!assetsDir.existsSync()) {
    printInfo(
      'No assets/images directory found in the active project at ${assetsDir.path}.',
    );
    return;
  }

  final images = assetsDir.listSync(recursive: true).whereType<File>().where((
    f,
  ) {
    final ext = p.extension(f.path).toLowerCase();
    return ['.png', '.jpg', '.jpeg'].contains(ext);
  }).toList();

  if (images.isEmpty) {
    printInfo('No PNG or JPG images found to bundle.');
    return;
  }

  int generatedCount = 0;

  await loadingSpinner(
    'Generating multi-density asset bundles (2x, 3x) in $activePath',
    () async {
      for (final file in images) {
        // Skip if already in a density folder
        if (file.path.contains('${p.separator}2.0x${p.separator}') ||
            file.path.contains('${p.separator}3.0x${p.separator}')) {
          continue;
        }

        final bytes = file.readAsBytesSync();
        final image = img.decodeImage(bytes);
        if (image == null) continue;

        final baseDir = file.parent.path;
        final fileName = p.basename(file.path);

        // Create 2.0x
        final dir2x = Directory(p.join(baseDir, '2.0x'));
        if (!dir2x.existsSync()) dir2x.createSync(recursive: true);
        final img2x = img.copyResize(
          image,
          width: (image.width * 0.66).toInt(),
        );
        File(
          p.join(dir2x.path, fileName),
        ).writeAsBytesSync(img.encodeNamedImage(fileName, img2x)!);

        // Create 3.0x
        final dir3x = Directory(p.join(baseDir, '3.0x'));
        if (!dir3x.existsSync()) dir3x.createSync(recursive: true);
        File(p.join(dir3x.path, fileName)).writeAsBytesSync(bytes);

        generatedCount += 2;
        printInfo('Bundled: $fileName (Generated 2.0x and 3.0x)');
      }
    },
  );

  print('\n$blue$bold📊 BUNDLE EFFICIENCY REPORT$reset');
  printTable(
    ['Metric', 'Value'],
    [
      ['Source Images', images.length.toString()],
      ['Density Variants Generated', generatedCount.toString()],
      ['Status', '✅ Optimized for High-DPI Screens'],
    ],
  );

  printSuccess('Asset bundling complete! Multi-density variants are ready.');
  ask('Press Enter to return');
}
