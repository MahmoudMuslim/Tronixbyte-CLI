import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> validateEnvSync() async {
  printSection('Environment Sync Validator');

  final activePath = getActiveProjectPath();
  final envFiles = ['.env.dev', '.env.stg', '.env.prod', '.env.example'];
  final Map<String, Set<String>> fileKeys = {};

  await loadingSpinner(
    'Analyzing environment file keys in $activePath',
    () async {
      for (final fileName in envFiles) {
        final file = File(p.join(activePath, fileName));
        if (!file.existsSync()) {
          continue;
        }

        final lines = file.readAsLinesSync();
        final keys = <String>{};
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
          final key = trimmed.split('=').first.trim();
          if (key.isNotEmpty) keys.add(key);
        }
        fileKeys[fileName] = keys;
      }
    },
  );

  if (fileKeys.isEmpty) {
    printWarning(
      'No environment files found to validate in the active project.',
    );
    return;
  }

  // Find all unique keys across all files
  final allKeys = fileKeys.values.expand((e) => e).toSet();
  bool isSynced = true;

  for (final fileName in fileKeys.keys) {
    final missingKeys = allKeys.difference(fileKeys[fileName]!);
    if (missingKeys.isNotEmpty) {
      printError('$fileName is missing: ${missingKeys.join(', ')}');
      isSynced = false;
    }
  }

  if (isSynced) {
    printSuccess('All environment files are perfectly synchronized!');
  } else {
    print('\n');
    printWarning(
      'Action Required: Synchronize your .env files to avoid runtime errors.',
    );
  }
}
