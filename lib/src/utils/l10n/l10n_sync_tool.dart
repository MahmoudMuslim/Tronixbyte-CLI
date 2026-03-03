import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> syncTranslations() async {
  printSection('Localization Sync Tool');

  final activePath = getActiveProjectPath();
  final l10nDir = Directory(p.join(activePath, 'assets', 'translations'));

  if (!l10nDir.existsSync()) {
    printError(
      'assets/translations directory not found in the active project at ${l10nDir.path}.',
    );
    return;
  }

  final files = l10nDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList();

  if (files.length < 2) {
    printInfo('Not enough translation files to sync in $activePath.');
    return;
  }

  // Find the master file (default to en.json, or the first one found)
  File? masterFile;
  for (final file in files) {
    if (file.path.endsWith('en.json')) {
      masterFile = file;
      break;
    }
  }
  masterFile ??= files.first;

  printInfo('Using ${p.basename(masterFile.path)} as source of truth.');

  await loadingSpinner(
    'Synchronizing translation keys across all locales in $activePath',
    () async {
      try {
        final Map<String, dynamic> masterData = json.decode(
          masterFile!.readAsStringSync(),
        );

        for (final file in files) {
          if (file.path == masterFile!.path) continue;

          final Map<String, dynamic> targetData = json.decode(
            file.readAsStringSync(),
          );
          bool updated = false;

          // Add missing keys
          for (final key in masterData.keys) {
            if (!targetData.containsKey(key)) {
              targetData[key] = "TODO: \${masterData[key]}";
              updated = true;
            }
          }

          if (updated) {
            const encoder = JsonEncoder.withIndent('  ');
            file.writeAsStringSync(encoder.convert(targetData));
            printInfo('Updated \${p.basename(file.path)}');
          }
        }
      } catch (e) {
        throw Exception('Error during sync: \$e');
      }
    },
  );

  printSuccess(
    'All translation files are now synchronized in the active project.',
  );
}
