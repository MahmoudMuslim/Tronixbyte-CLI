import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runEnvSecretWizard() async {
  printSection('Environment Secret Wizard');

  final activePath = getActiveProjectPath();

  printInfo(
    'This tool helps you set up and sync sensitive keys across your environments in $activePath.',
  );

  final keys = [
    'BASE_URL',
    'API_KEY',
    'FIREBASE_PROJECT_ID',
    'MAPS_API_KEY',
    'SENTRY_DSN',
  ];

  final Map<String, String> values = {};
  for (final key in keys) {
    final value = ask('Enter value for $key');
    if (value != null) {
      values[key] = value;
    }
  }

  if (values.isEmpty) {
    printInfo('No changes made.');
    return;
  }

  await loadingSpinner(
    'Synchronizing secrets across all environments in $activePath',
    () async {
      final envs = ['dev', 'stg', 'prod'];
      for (final env in envs) {
        final file = File(p.join(activePath, '.env.$env'));
        final Map<String, String> currentEnvData = {};

        if (file.existsSync()) {
          final lines = file.readAsLinesSync();
          for (final line in lines) {
            if (line.contains('=')) {
              final parts = line.split('=');
              currentEnvData[parts[0].trim()] = parts
                  .sublist(1)
                  .join('=')
                  .trim();
            }
          }
        }

        // Merge new values
        values.forEach((k, v) => currentEnvData[k] = v);

        final buffer = StringBuffer();
        currentEnvData.forEach((k, v) => buffer.writeln('$k=$v'));
        // Use write mode to avoid duplicating content
        file.writeAsStringSync(buffer.toString());
        printInfo('Updated .env.$env');
      }

      // Update .env.example (without values)
      final exampleFile = File(p.join(activePath, '.env.example'));
      final exampleBuffer = StringBuffer();
      final exampleKeys = {...values.keys};
      if (exampleFile.existsSync()) {
        final lines = exampleFile.readAsLinesSync();
        for (final line in lines) {
          if (line.contains('=')) {
            exampleKeys.add(line.split('=')[0].trim());
          }
        }
      }

      final sortedKeys = exampleKeys.toList()..sort();
      for (final key in sortedKeys) {
        exampleBuffer.writeln('$key=');
      }
      exampleFile.writeAsStringSync(exampleBuffer.toString());
      printInfo('Updated .env.example (template)');
    },
  );

  printSuccess('Secrets successfully synchronized across all environments!');
}
