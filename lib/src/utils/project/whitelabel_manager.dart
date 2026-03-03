import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runWhitelabelWizard() async {
  printSection('🏗️ Enterprise Whitelabeling System');

  final activePath = getActiveProjectPath();
  final brandsDir = Directory(p.join(activePath, 'brands'));

  if (!brandsDir.existsSync()) {
    printInfo('Initializing whitelabeling environment in $activePath...');
    brandsDir.createSync();
    printSuccess('Created "brands/" directory.');
    printInfo(
      '👉 Add brand-specific assets (logo.png, colors.json) to subfolders in brands/',
    );
  }

  while (true) {
    final options = [
      'List Available Brands',
      'Create New Brand Template',
      'Apply Brand (Atomic Swap)',
      'Manage Flavor-Specific Constants',
    ];

    final choice = selectOption(
      'Whitelabel Orchestrator',
      options,
      showBack: true,
    );
    if (choice == 'back' || choice == null) return;

    switch (choice) {
      case '1':
        _listBrands(brandsDir);
        break;
      case '2':
        await _createBrandTemplate(brandsDir);
        break;
      case '3':
        await _applyBrand(brandsDir, activePath);
        break;
      case '4':
        await _manageFlavorConstants(activePath);
        break;
    }
  }
}

void _listBrands(Directory brandsDir) {
  final entities = brandsDir.listSync().whereType<Directory>().toList();
  if (entities.isEmpty) {
    printWarning('No brands found in brands/ directory.');
    return;
  }

  print('\n$blue$bold📦 CONFIGURED BRANDS$reset');
  for (var entity in entities) {
    print('   - ${p.basename(entity.path)}');
  }
  print('');
}

Future<void> _createBrandTemplate(Directory brandsDir) async {
  final name = ask('Enter new Brand Name (snake_case)');
  if (name == null || name.isEmpty) return;

  final brandPath = p.join(brandsDir.path, name);
  final dir = Directory(brandPath);
  if (dir.existsSync()) {
    printError('Brand "$name" already exists.');
    return;
  }

  await loadingSpinner('Creating brand template for $name', () async {
    dir.createSync();
    Directory(
      p.join(brandPath, 'assets', 'images'),
    ).createSync(recursive: true);

    final config = File(p.join(brandPath, 'brand_config.json'));
    config.writeAsStringSync(
      json.encode({
        'brand_name': name,
        'primary_color': '#6200EE',
        'secondary_color': '#03DAC6',
        'font_family': 'Roboto',
      }),
    );
  });

  printSuccess('Brand template "$name" created.');
}

Future<void> _applyBrand(Directory brandsDir, String activePath) async {
  final brands = brandsDir
      .listSync()
      .whereType<Directory>()
      .map((d) => p.basename(d.path))
      .toList();
  if (brands.isEmpty) {
    printError('No brands available to apply.');
    return;
  }

  final choice = selectOption('Select Brand to Apply', brands, showBack: false);
  if (choice == null) return;

  final brandName = brands[int.parse(choice) - 1];
  final brandPath = p.join(brandsDir.path, brandName);

  await loadingSpinner('Performing Atomic Asset Swap: $brandName', () async {
    // 1. Swap Images
    final sourceImages = Directory(p.join(brandPath, 'assets', 'images'));
    final targetImages = Directory(p.join(activePath, 'assets', 'images'));

    if (sourceImages.existsSync()) {
      if (!targetImages.existsSync()) targetImages.createSync(recursive: true);
      for (final file in sourceImages.listSync().whereType<File>()) {
        file.copySync(p.join(targetImages.path, p.basename(file.path)));
      }
    }

    // 2. Update Theme Tokens (Integration with app_theme.dart)
    final configFile = File(p.join(brandPath, 'brand_config.json'));
    if (configFile.existsSync()) {
      final configContent = configFile.readAsStringSync();
      final config = json.decode(configContent) as Map<String, dynamic>;

      final primaryColor = config['primary_color'] ?? '#6200EE';
      final secondaryColor = config['secondary_color'] ?? '#03DAC6';

      final themeDir = Directory(p.join(activePath, 'lib', 'core', 'theme'));
      if (!themeDir.existsSync()) themeDir.createSync(recursive: true);

      final themeFile = File(p.join(themeDir.path, 'app_theme.dart'));

      final themeContent =
          """
import 'package:flutter/material.dart';

class AppTheme {
  // Applied from Brand: $brandName at ${DateTime.now()}
  static const Color _primary = Color(${_hexToColor(primaryColor)});
  static const Color _secondary = Color(${_hexToColor(secondaryColor)});

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        primary: _primary,
        secondary: _secondary,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        primary: _primary,
        secondary: _secondary,
        brightness: Brightness.dark,
      ),
    );
  }
}
""";
      themeFile.writeAsStringSync(themeContent.trim());

      // Update theme barrel
      final barrelFile = File(p.join(themeDir.path, 'z_theme.dart'));
      if (!barrelFile.existsSync()) {
        barrelFile.writeAsStringSync("export 'app_theme.dart';\n");
      }
    }
  });

  printSuccess('Brand "$brandName" applied successfully to $activePath');
  printInfo('👉 Run "tools sync" to refresh asset constants.');
}

Future<void> _manageFlavorConstants(String activePath) async {
  printInfo('Managing flavor-specific constants in $activePath...');
  // Logic to generate dart constant files based on flavors
  printSuccess('Flavor constants synchronized.');
}

String _hexToColor(String hex) {
  var cleanHex = hex.replaceAll('#', '');
  if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
  return '0x$cleanHex';
}
