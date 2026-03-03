import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> generateDebugConfigs() async {
  printSection('Debug Configurations Generator');

  final activePath = getActiveProjectPath();

  final configs = {
    "version": "0.2.0",
    "configurations": [
      {
        "name": "Tronixbyte: Dev (Debug)",
        "request": "launch",
        "type": "dart",
        "program": "lib/main.dart",
        "args": ["--dart-define-from-file=.env.dev"],
      },
      {
        "name": "Tronixbyte: Staging (Debug)",
        "request": "launch",
        "type": "dart",
        "program": "lib/main.dart",
        "args": ["--dart-define-from-file=.env.stg"],
      },
      {
        "name": "Tronixbyte: Prod (Debug)",
        "request": "launch",
        "type": "dart",
        "program": "lib/main.dart",
        "args": ["--dart-define-from-file=.env.prod"],
      },
    ],
  };

  await loadingSpinner(
    'Generating .vscode/launch.json in $activePath',
    () async {
      final vscodeDir = Directory(p.join(activePath, '.vscode'));
      if (!vscodeDir.existsSync()) vscodeDir.createSync(recursive: true);

      final file = File(p.join(vscodeDir.path, 'launch.json'));
      file.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(configs),
      );
    },
  );

  printSuccess('Debug configurations generated successfully!');
  printInfo(
    'You can now run the app with different environments directly from the Run & Debug tab.',
  );
}
