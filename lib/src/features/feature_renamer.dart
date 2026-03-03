import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> promptRenameFeature() async {
  printSection('Feature Renaming Wizard');

  final oldName = ask('Enter the current Feature Name (e.g., auth)');
  if (oldName == null || oldName.isEmpty) return;

  final newName = ask('Enter the NEW Feature Name (e.g., identity)');
  if (newName == null || newName.isEmpty) return;

  final confirm =
      (ask('Rename feature "$oldName" to "$newName"? (y/n)') ?? 'n')
          .toLowerCase() ==
      'y';
  if (!confirm) {
    printInfo('Renaming cancelled.');
    return;
  }

  await renameFeature(oldName, newName);
}

Future<void> renameFeature(String oldName, String newName) async {
  final oldPascal = oldName[0].toUpperCase() + oldName.substring(1);
  final newPascal = newName[0].toUpperCase() + newName.substring(1);
  final oldPath = 'lib/features/$oldName';
  final newPath = 'lib/features/$newName';

  if (!Directory(oldPath).existsSync()) {
    printError('Feature "$oldName" not found at $oldPath');
    return;
  }

  await loadingSpinner('Renaming feature: $oldName -> $newName', () async {
    // 1. Rename files and update contents inside the feature directory
    final featureDir = Directory(oldPath);
    final entities = featureDir.listSync(recursive: true);

    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.dart')) {
        String content = entity.readAsStringSync();

        // Update class names and imports
        content = content.replaceAll(oldPascal, newPascal);
        content = content.replaceAll(oldName, newName);

        // Correctly overwrite content
        entity.writeAsStringSync(content);

        // Rename file if it contains the old name
        final fileName = p.basename(entity.path);
        if (fileName.contains(oldName)) {
          final newFileName = fileName.replaceAll(oldName, newName);
          final newFilePath = p.join(p.dirname(entity.path), newFileName);
          entity.renameSync(newFilePath);
        }
      }
    }

    // 2. Rename the directory itself
    featureDir.renameSync(newPath);
    printInfo('Renamed directory to: $newPath');

    // 3. Update lib/injection.dart
    final injectionFile = File('lib/injection.dart');
    if (injectionFile.existsSync()) {
      String content = injectionFile.readAsStringSync();
      content = content.replaceAll(
        'init${oldPascal}Injection',
        'init${newPascal}Injection',
      );
      injectionFile.writeAsStringSync(content);
      printInfo('Updated lib/injection.dart');
    }

    // 4. Update lib/features/z_features.dart
    final barrelFile = File('lib/features/z_features.dart');
    if (barrelFile.existsSync()) {
      String content = barrelFile.readAsStringSync();
      content = content.replaceAll(oldName, newName);
      barrelFile.writeAsStringSync(content);
      printInfo('Updated lib/features/z_features.dart');
    }
  });

  printSuccess('Feature successfully renamed!');
  printInfo('👉 Remember to run build_runner if you have generated files.');
}
