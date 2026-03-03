import 'package:tools/tools.dart';

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
  final featurePath = 'lib/features/$name';

  await loadingSpinner('Removing feature: $name', () async {
    // 1. Delete directories
    final dir = Directory(featurePath);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
      printInfo('Deleted directory: $featurePath');
    } else {
      printWarning('Feature directory not found.');
    }

    // 2. Unwire Injection
    final injectionFile = File('lib/injection.dart');
    if (injectionFile.existsSync()) {
      String content = injectionFile.readAsStringSync();
      final initCall = '  await init${namePascal}Injection();';
      if (content.contains(initCall)) {
        content = content.replaceFirst('$initCall\n', '');
        content = content.replaceFirst(initCall, '');
        injectionFile.writeAsStringSync(content);
        printInfo('Unwired from lib/injection.dart');
      }
    }
  });

  printSuccess('Feature $name has been removed successfully!');
  printWarning(
    'Note: If this feature had a route, you may need to manually remove it from lib/core/routes/router.dart',
  );
}
