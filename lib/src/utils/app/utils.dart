import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

void updatePubspecAssets() {
  final activePath = getActiveProjectPath();
  final file = File(p.join(activePath, 'pubspec.yaml'));
  if (!file.existsSync()) return;
  String content = file.readAsStringSync();

  final folders = [
    'assets/translations/',
    'assets/images/',
    'assets/fonts/',
    'assets/svgs/',
  ];

  for (final folder in folders) {
    if (Directory(
          p.join(activePath, folder.replaceAll('/', '')),
        ).existsSync() &&
        !content.contains(folder)) {
      if (content.contains('  assets:')) {
        content = content.replaceFirst('  assets:', '  assets:\n    - $folder');
      } else if (content.contains('flutter:')) {
        content = content.replaceFirst(
          'flutter:',
          'flutter:\n  assets:\n    - $folder',
        );
      }
    }
  }

  if (File(p.join(activePath, '.env')).existsSync() &&
      !content.contains('- .env')) {
    if (content.contains('  assets:')) {
      content = content.replaceFirst('  assets:', '  assets:\n    - .env');
    }
  }

  file.writeAsStringSync(content);
  printSuccess('Pubspec assets synchronized.');
}

void updateServiceBarrel(String fileName) {
  final activePath = getActiveProjectPath();
  final barrelFile = File(
    p.join(activePath, 'lib/core/services/z_services.dart'),
  );
  final exportLine = "export '$fileName';\n";
  if (!barrelFile.existsSync()) {
    if (!barrelFile.parent.existsSync()) {
      barrelFile.parent.createSync(recursive: true);
    }
    barrelFile.writeAsStringSync(exportLine);
  } else {
    String content = barrelFile.readAsStringSync();
    if (!content.contains(fileName)) {
      barrelFile.writeAsStringSync('$content$exportLine');
    }
  }
}

Future<void> wireCoreInjection(String className) async {
  final activePath = getActiveProjectPath();
  final injectionFile = File(p.join(activePath, 'lib/injection.dart'));
  if (!injectionFile.existsSync()) return;
  String content = injectionFile.readAsStringSync();
  if (!content.contains(className)) {
    content = content.replaceFirst(
      '// --- Core ---',
      '// --- Core ---\n  sl.registerLazySingleton(() => $className());',
    );
    injectionFile.writeAsStringSync(content);
  }
}
