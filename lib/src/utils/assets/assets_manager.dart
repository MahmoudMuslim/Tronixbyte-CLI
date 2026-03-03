import 'package:tools/tools.dart';

Future<void> manageAssets() async {
  while (true) {
    final options = [
      'Initialize standard assets structure',
      'Sync assets with pubspec.yaml',
      'Generate type-safe Asset Constants (AppAssets)',
    ];

    final choice = selectOption('Assets Management', options, showBack: true);

    switch (choice) {
      case '1':
        await _initAssetsStructure();
        break;
      case '2':
        updatePubspecAssets();
        break;
      case '3':
        await generateAssetConstants();
        break;
      case 'back':
        return;
      case null:
        break;
      default:
        printError('Invalid option.');
    }
  }
}

Future<void> _initAssetsStructure() async {
  final folders = [
    'assets/images',
    'assets/fonts',
    'assets/svgs',
    'assets/translations',
    'assets/db',
  ];

  await loadingSpinner('Initializing asset infrastructure', () async {
    for (final folder in folders) {
      final dir = Directory(folder);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
        printInfo('Created: $folder');
      }
    }
    updatePubspecAssets();
  });

  printSuccess('Asset structure initialized and synced with pubspec.yaml');
}
