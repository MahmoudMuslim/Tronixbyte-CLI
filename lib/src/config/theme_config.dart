import 'package:tools/tools.dart';

Future<void> configureThemeAndLocale(
  String projectName,
  String stateType,
) async {
  printSection('Theme & Locale Configuration');

  final logicDir = _getLogicDir(stateType);
  final themeDir = Directory('lib/core/theme/manager');
  final localeDir = Directory('lib/core/locale/manager');

  await loadingSpinner(
    'Scaffolding multi-platform theme and localization logic',
    () async {
      if (!themeDir.existsSync()) themeDir.createSync(recursive: true);
      if (!localeDir.existsSync()) localeDir.createSync(recursive: true);

      // 1. Generate Theme Logic
      final themeFile = File('${themeDir.path}/theme_$logicDir.dart');
      themeFile.writeAsStringSync(getThemeTemplate(projectName, stateType));
      printInfo('Generated: ${themeFile.path}');

      final themeStateFile = File('${themeDir.path}/theme_state.dart');
      if (stateType == 'bloc' || stateType == 'cubit') {
        themeStateFile.writeAsStringSync(getThemeStateTemplate(stateType));
      } else {
        themeStateFile.writeAsStringSync(
          getThemeStateGenericTemplate(stateType),
        );
      }
      printInfo('Generated: ${themeStateFile.path}');

      // 2. Generate App Theme (Static styles)
      final appThemeFile = File('lib/core/theme/app_theme.dart');
      appThemeFile.writeAsStringSync(getAppThemeTemplate(projectName));
      printInfo('Generated: lib/core/theme/app_theme.dart');

      final themeBarrelFile = File('lib/core/theme/z_theme.dart');
      themeBarrelFile.writeAsStringSync(
        "export 'manager/theme_$logicDir.dart';\nexport 'app_theme.dart';",
      );

      // 3. Generate Locale Logic
      final localeFile = File('${localeDir.path}/locale_$logicDir.dart');
      localeFile.writeAsStringSync(getLocaleTemplate(projectName, stateType));
      printInfo('Generated: ${localeFile.path}');

      final localeStateFile = File('${localeDir.path}/locale_state.dart');
      if (stateType == 'bloc' || stateType == 'cubit') {
        localeStateFile.writeAsStringSync(getLocaleStateTemplate(stateType));
      } else {
        localeStateFile.writeAsStringSync(
          getLocaleStateGenericTemplate(stateType),
        );
      }
      printInfo('Generated: ${localeStateFile.path}');

      final localeBarrelFile = File('lib/core/locale/z_locale.dart');
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
    default:
      return 'provider';
  }
}
