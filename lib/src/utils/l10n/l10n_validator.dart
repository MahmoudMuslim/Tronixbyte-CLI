import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> validateLocalization() async {
  printSection('Localization Validator');

  final activePath = getActiveProjectPath();
  final enFile = File(p.join(activePath, 'assets', 'translations', 'en.json'));
  final arFile = File(p.join(activePath, 'assets', 'translations', 'ar.json'));

  if (!enFile.existsSync() || !arFile.existsSync()) {
    printWarning(
      'Standard translation files (en.json, ar.json) not found in the active project. Skipping validation.',
    );
    return;
  }

  await loadingSpinner(
    'Validating localization synchronization in $activePath',
    () async {
      try {
        final Map<String, dynamic> enJson = json.decode(
          enFile.readAsStringSync(),
        );
        final Map<String, dynamic> arJson = json.decode(
          arFile.readAsStringSync(),
        );

        final enKeys = enJson.keys.toSet();
        final arKeys = arJson.keys.toSet();

        final missingInAr = enKeys.difference(arKeys);
        final missingInEn = arKeys.difference(enKeys);

        if (missingInAr.isEmpty && missingInEn.isEmpty) {
          printSuccess('Localization is perfectly synchronized.');
        } else {
          if (missingInAr.isNotEmpty) {
            printError('Missing in Arabic: ${missingInAr.join(', ')}');
          }
          if (missingInEn.isNotEmpty) {
            printError('Missing in English: ${missingInEn.join(', ')}');
          }
        }
      } catch (e) {
        printError('Error parsing localization files: \$e');
      }
    },
  );
}
