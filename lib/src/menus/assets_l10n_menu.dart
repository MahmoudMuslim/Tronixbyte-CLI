import 'package:tools/tools.dart';

Future<void> assetsAndL10nMenu() async {
  while (true) {
    final options = [
      'Manage Assets Folders (Initialize & Sync)',
      'Generate Asset Constants (AppAssets)',
      'Smart Asset Optimizer (Convert PNG/JPG to WebP)',
      'Performance-Driven Asset Bundling (2x, 3x)',
      'Production Asset Bundle (Pre-Flight)',
      'Add NEW Localization Key (Wizard)',
      'Generate Localization Keys (easy_localization)',
      'Sync Translation Keys (Master -> Others)',
      'AI Translation Wizard (Gemini)',
    ];

    final choice = selectOption(
      'Assets & Localization',
      options,
      showBack: true,
    );

    switch (choice) {
      case '1':
        await manageAssets();
        break;
      case '2':
        await generateAssetConstants();
        break;
      case '3':
        await optimizeProjectAssets();
        break;
      case '4':
        await runPerformanceAssetBundling();
        break;
      case '5':
        await runAssetPreflight();
        break;
      case '6':
        await addLocalizationKey();
        break;
      case '7':
        await runCommand('dart', [
          'run',
          'easy_localization:generate',
          '-S',
          'assets/translations',
          '-f',
          'keys',
          '-o',
          'locale_keys.g.dart',
          '-O',
          'lib/l10n',
        ], loadingMessage: 'Generating localization keys');
        break;
      case '8':
        await syncTranslations();
        break;
      case '9':
        await runAiTranslator();
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
