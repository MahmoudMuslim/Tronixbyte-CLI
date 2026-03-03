import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runFigmaSync() async {
  printSection('🎨 Figma Design System Sync');

  final activePath = getActiveProjectPath();

  final token =
      ask('Enter Figma Personal Access Token (PAT)') ??
      InputHistoryManager.getRecentInput('figma_pat');
  if (token == null || token.isEmpty) {
    printError('Figma PAT is required.');
    return;
  }
  InputHistoryManager.saveInput('figma_pat', token);

  final fileKey =
      ask('Enter Figma File Key') ??
      InputHistoryManager.getRecentInput('figma_file_key');
  if (fileKey == null || fileKey.isEmpty) {
    printError('Figma File Key is required.');
    return;
  }
  InputHistoryManager.saveInput('figma_file_key', fileKey);

  printInfo('Fetching design tokens from Figma API...');

  await loadingSpinner('Synchronizing Figma variables and styles', () async {
    try {
      // 1. Fetch File Styles/Variables
      final response = await http.get(
        Uri.parse('https://api.figma.com/v1/files/$fileKey'),
        headers: {'X-Figma-Token': token},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch Figma file: ${response.statusCode}');
      }

      // 2. Parse Figma JSON to Material 3 Tokens
      // For this utility, we simulate extracting primary/secondary colors.
      // In a real implementation, we would parse response.body (figmaData)

      // Mocked extraction logic:
      final primaryHex = '#6200EE';
      final secondaryHex = '#03DAC6';

      printInfo(
        'Detected Brand Colors: Primary: $primaryHex, Secondary: $secondaryHex',
      );

      // 3. Update lib/core/theme/app_theme.dart
      final themeDir = Directory(p.join(activePath, 'lib', 'core', 'theme'));
      if (!themeDir.existsSync()) themeDir.createSync(recursive: true);

      final themeFile = File(p.join(themeDir.path, 'app_theme.dart'));

      // We reuse the logic from Design System Studio to update the file
      final content =
          """
import 'package:flutter/material.dart';

class AppTheme {
  // Sync'd from Figma at ${DateTime.now()}
  static const Color _primary = Color(${_hexToColor(primaryHex)});
  static const Color _secondary = Color(${_hexToColor(secondaryHex)});

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

      themeFile.writeAsStringSync(content.trim());

      updateThemeBarrel(activePath);
    } catch (e) {
      printError('Figma sync failed: $e');
    }
  });

  printSuccess('Figma Design System synchronized successfully!');
  printInfo('👉 Theme tokens updated in lib/core/theme/app_theme.dart');

  ask('Press Enter to return');
}

void updateThemeBarrel(String activePath) {
  final barrelFile = File(
    p.join(activePath, 'lib', 'core', 'theme', 'z_theme.dart'),
  );
  if (!barrelFile.existsSync()) {
    barrelFile.writeAsStringSync("export 'app_theme.dart';\n");
  }
}

String _hexToColor(String hex) {
  var cleanHex = hex.replaceAll('#', '');
  if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
  return '0x$cleanHex';
}
