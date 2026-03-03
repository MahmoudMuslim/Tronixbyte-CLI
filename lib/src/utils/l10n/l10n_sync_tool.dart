import 'package:tools/tools.dart';

Future<void> syncTranslations() async {
  printSection('Localization Sync Tool');
  final l10nDir = Directory('assets/translations');
  if (!l10nDir.existsSync()) {
    printError('assets/translations directory not found.');
    return;
  }

  final files = l10nDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList();

  if (files.length < 2) {
    printInfo('Not enough translation files to sync.');
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

  printInfo(
    'Using ${masterFile.path.split(Platform.pathSeparator).last} as source of truth.',
  );

  await loadingSpinner(
    'Synchronizing translation keys across all locales',
    () async {
      try {
        final Map<String, dynamic> masterData = json.decode(
          masterFile!.readAsStringSync(),
        );

        for (final file in files) {
          if (file.path == masterFile.path) continue;

          final Map<String, dynamic> targetData = json.decode(
            file.readAsStringSync(),
          );
          bool updated = false;

          // Add missing keys
          for (final key in masterData.keys) {
            if (!targetData.containsKey(key)) {
              targetData[key] = "TODO: ${masterData[key]}";
              updated = true;
            }
          }

          // Optional: Remove extra keys that aren't in master
          final extraKeys = targetData.keys
              .where((k) => !masterData.containsKey(k))
              .toList();

          if (extraKeys.isNotEmpty) {
            // We can't ask inside loadingSpinner without breaking the UI flow
            // So we either skip or handle it before/after
            // For now, let's just keep the keys to be safe during automated sync
          }

          if (updated) {
            const encoder = JsonEncoder.withIndent('  ');
            file.writeAsStringSync(encoder.convert(targetData));
            printInfo(
              'Updated ${file.path.split(Platform.pathSeparator).last}',
            );
          }
        }
      } catch (e) {
        throw Exception('Error during sync: $e');
      }
    },
  );

  printSuccess('All translation files are now synchronized.');
}
