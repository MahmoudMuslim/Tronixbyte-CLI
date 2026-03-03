import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runDesignSystemStudio() async {
  printSection('🎨 Design System Studio (Material 3)');

  final activePath = getActiveProjectPath();
  printInfo('Designing tokens for project at $activePath');

  final primaryColor =
      ask('Enter Primary Color (HEX, e.g., #6200EE)') ?? '#6200EE';
  final secondaryColor =
      ask('Enter Secondary Color (HEX, e.g., #03DAC6)') ?? '#03DAC6';
  final useDarkTheme =
      (ask('Generate Dark Theme too? (y/n)') ?? 'y').toLowerCase() == 'y';

  await loadingSpinner(
    'Generating Design System tokens and Theme configuration',
    () async {
      final themeDir = Directory(p.join(activePath, 'lib', 'core', 'theme'));
      if (!themeDir.existsSync()) themeDir.createSync(recursive: true);

      final themeFile = File(p.join(themeDir.path, 'app_theme.dart'));

      final content =
          """
import 'package:flutter/material.dart';

class AppTheme {
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
      // Custom TextThemes, ButtonThemes, etc. can be scaffolded here
    );
  }

  ${useDarkTheme ? """
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
  """ : ""}
}
""";

      themeFile.writeAsStringSync(content.trim());

      // Update theme barrel
      final barrelFile = File(p.join(themeDir.path, 'z_theme.dart'));
      if (!barrelFile.existsSync()) {
        barrelFile.writeAsStringSync("export 'app_theme.dart';\n");
      } else {
        String barrelContent = barrelFile.readAsStringSync();
        if (!barrelContent.contains('app_theme.dart')) {
          barrelFile.writeAsStringSync(
            "${barrelContent.trim()}\nexport 'app_theme.dart';\n",
          );
        }
      }
    },
  );

  printSuccess('Design System Studio: Theme tokens generated successfully!');
  printInfo('👉 Check lib/core/theme/app_theme.dart');

  ask('Press Enter to return');
}

String _hexToColor(String hex) {
  var cleanHex = hex.replaceAll('#', '');
  if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
  return '0x$cleanHex';
}
