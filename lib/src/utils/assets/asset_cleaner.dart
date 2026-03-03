import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> findUnusedAssets() async {
  printSection('Unused Asset Cleaner');

  final assetsDir = Directory('assets');
  if (!assetsDir.existsSync()) {
    printInfo('No assets directory found.');
    return;
  }

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    printError('lib directory not found.');
    return;
  }

  final allAssets = assetsDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => !p.basename(f.path).startsWith('.'))
      .toList();

  if (allAssets.isEmpty) {
    printInfo('No asset files found in assets/ folder.');
    return;
  }

  final List<String> unusedAssets = [];

  await loadingSpinner('Analyzing asset usage across lib/', () async {
    final libFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    for (final asset in allAssets) {
      final assetName = p.basename(asset.path);
      final assetPath = p
          .relative(asset.path, from: Directory.current.path)
          .replaceAll('\\', '/');

      bool isUsed = false;
      for (final file in libFiles) {
        final content = file.readAsStringSync();
        // Check for filename or full path reference
        if (content.contains(assetName) || content.contains(assetPath)) {
          isUsed = true;
          break;
        }
      }

      if (!isUsed) {
        unusedAssets.add(assetPath);
      }
    }
  });

  if (unusedAssets.isEmpty) {
    printSuccess('Great job! All assets appear to be in use.');
  } else {
    printWarning('Found ${unusedAssets.length} potentially unused assets:');
    for (final asset in unusedAssets) {
      print('      - $asset');
    }

    print(
      '\n$yellow$bold💡 Tip:$reset Double-check if these are used dynamically before deleting.',
    );

    final delete =
        (ask('Do you want to delete them all now? (y/n)') ?? 'n')
            .toLowerCase() ==
        'y';
    if (delete) {
      await loadingSpinner('Deleting unused files', () async {
        for (final path in unusedAssets) {
          File(path).deleteSync();
        }
      });
      printSuccess('Deleted ${unusedAssets.length} files.');
    }
  }
}
