import 'package:tools/tools.dart';
import 'package:path/path.dart' as p;

Future<void> promptRemoveFeature() async {
  printSection('Feature Removal Wizard');

  final name = ask('Enter the Feature Name to DELETE (e.g., auth)');
  if (name == null || name.isEmpty) return;

  final confirm =
      (ask(
                'Are you SURE you want to delete feature "$name"? This cannot be undone! (y/n)',
              ) ??
              'n')
          .toLowerCase() ==
      'y';
  if (!confirm) {
    printInfo('Deletion cancelled.');
    return;
  }

  await removeFeature(name);
}

Future<void> removeFeature(String name) async {
  final namePascal = name[0].toUpperCase() + name.substring(1);
  final activePath = getActiveProjectPath();
  final featurePath = p.join(activePath, 'lib', 'features', name);

  await loadingSpinner('Removing feature: $name', () async {
    // 1. Delete directories
    final dir = Directory(featurePath);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
      printInfo('Deleted directory: $featurePath');
    } else {
      printWarning('Feature directory not found at $featurePath');
    }

    // 2. Unwire Injection
    final injectionFile = File(p.join(activePath, 'lib', 'injection.dart'));
    if (injectionFile.existsSync()) {
      String content = injectionFile.readAsStringSync();
      final initCall = '  await init${namePascal}Injection();';
      if (content.contains(initCall)) {
        content = content.replaceFirst('$initCall\n', '');
        content = content.replaceFirst(initCall, '');
        injectionFile.writeAsStringSync(content);
        printInfo('Unwired from ${injectionFile.path}');
      }
    }

    // 3. Update lib/features/z_features.dart
    final barrelFile = File(
      p.join(activePath, 'lib', 'features', 'z_features.dart'),
    );
    if (barrelFile.existsSync()) {
      String content = barrelFile.readAsStringSync();
      final exportLine = "export '$name/z_$name.dart';\n";
      final exportLineAlt = "export '$name/z_$name.dart';";

      content = content.replaceAll(exportLine, '');
      content = content.replaceAll(exportLineAlt, '');
      barrelFile.writeAsStringSync(content);
      printInfo('Updated barrel at ${barrelFile.path}');
    }
  });

  printSuccess('Feature $name has been removed successfully!');
  printWarning(
    'Note: If this feature had a route, you may need to manually remove it from lib/core/routes/router.dart',
  );
}
