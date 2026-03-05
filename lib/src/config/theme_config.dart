import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> configureThemeAndLocale(
  String projectName,
  String stateType,
) async {
  printSection('Theme & Locale Configuration');

  final activePath = getActiveProjectPath();
  final logicDir = _getLogicDir(stateType);
  final themeDir = Directory(
    p.join(activePath, 'lib', 'core', 'theme', 'manager'),
  );
  final localeDir = Directory(
    p.join(activePath, 'lib', 'core', 'locale', 'manager'),
  );

  await loadingSpinner(
    'Scaffolding multi-platform theme and localization logic',
    () async {
      if (!themeDir.existsSync()) themeDir.createSync(recursive: true);
      if (!localeDir.existsSync()) localeDir.createSync(recursive: true);

      // 1. Generate Theme Logic
      final themeFile = File(p.join(themeDir.path, 'theme_$logicDir.dart'));
      themeFile.writeAsStringSync(
        getThemeTemplate(projectName, stateType, logicDir),
      );
      printInfo('Generated: ${themeFile.path}');

      final themeStateFile = File(p.join(themeDir.path, 'theme_state.dart'));
      themeStateFile.writeAsStringSync(
        getThemeStateTemplate(stateType, logicDir),
      );
      printInfo('Generated: ${themeStateFile.path}');

      // 2. Generate App Theme (Static styles)
      final appThemeFile = File(
        p.join(activePath, 'lib', 'core', 'theme', 'app_theme.dart'),
      );
      appThemeFile.writeAsStringSync(getAppThemeTemplate(projectName));
      printInfo('Generated: ${appThemeFile.path}');

      final themeBarrelFile = File(
        p.join(activePath, 'lib', 'core', 'theme', 'z_theme.dart'),
      );
      themeBarrelFile.writeAsStringSync(
        "export 'manager/theme_$logicDir.dart';\nexport 'app_theme.dart';",
      );

      // 3. Generate Locale Logic
      final localeFile = File(p.join(localeDir.path, 'locale_$logicDir.dart'));
      localeFile.writeAsStringSync(
        getLocaleTemplate(projectName, stateType, logicDir),
      );
      printInfo('Generated: ${localeFile.path}');

      final localeStateFile = File(p.join(localeDir.path, 'locale_state.dart'));
      localeStateFile.writeAsStringSync(
        getLocaleStateTemplate(stateType, logicDir),
      );

      printInfo('Generated: ${localeStateFile.path}');

      final localeBarrelFile = File(
        p.join(activePath, 'lib', 'core', 'locale', 'z_locale.dart'),
      );
      localeBarrelFile.writeAsStringSync(
        "export 'manager/locale_$logicDir.dart';",
      );
    },
  );

  printSuccess(
    'Theme & Locale infrastructure configured successfully for $stateType!',
  );
}

String _getLogicDir(String stateType) {
  switch (stateType) {
    case 'bloc':
      return 'bloc';
    case 'cubit':
      return 'cubit';
    case 'getx':
      return 'controller';
    case 'riverpod':
      return 'riverpod';
    case 'provider':
      return 'provider';
    default:
      return 'cubit';
  }
}
