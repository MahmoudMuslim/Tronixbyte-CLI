import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> findUnusedAssets() async {
  printSection('Unused Asset Cleaner');

  final activePath = getActiveProjectPath();
  final assetsDir = Directory(p.join(activePath, 'assets'));
  if (!assetsDir.existsSync()) {
    printInfo('No assets directory found at ${assetsDir.path}.');
    return;
  }

  final libDir = Directory(p.join(activePath, 'lib'));
  if (!libDir.existsSync()) {
    printError('lib directory not found at ${libDir.path}.');
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

  final List<String> unusedAssetsPaths = [];

  await loadingSpinner(
    'Analyzing asset usage across lib/ in $activePath',
    () async {
      final libFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();

      for (final asset in allAssets) {
        final assetName = p.basename(asset.path);
        // We use the path relative to project root for string matching in code
        final assetPath = p
            .relative(asset.path, from: activePath)
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
          unusedAssetsPaths.add(asset.path); // Store absolute path for deletion
        }
      }
    },
  );

  if (unusedAssetsPaths.isEmpty) {
    printSuccess('Great job! All assets appear to be in use.');
  } else {
    printWarning(
      'Found ${unusedAssetsPaths.length} potentially unused assets:',
    );
    for (final assetAbsPath in unusedAssetsPaths) {
      print('      - ${p.relative(assetAbsPath, from: activePath)}');
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
        for (final path in unusedAssetsPaths) {
          File(path).deleteSync();
        }
      });
      printSuccess('Deleted ${unusedAssetsPaths.length} files.');
    }
  }
}
