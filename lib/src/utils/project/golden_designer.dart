import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runGoldenDesigner() async {
  printSection('🧪 Golden Test Designer');

  final activePath = getActiveProjectPath();
  final projectName = await getProjectName();
  final featuresDir = Directory(p.join(activePath, 'lib', 'features'));

  if (!featuresDir.existsSync()) {
    printError('lib/features directory not found at ${featuresDir.path}.');
    return;
  }

  printInfo(
    'This tool will help you design visual expectations for your screens in $activePath.',
  );

  final screens = featuresDir
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (f) =>
            f.path.contains('presentation/screens') && f.path.endsWith('.dart'),
      )
      .toList();

  if (screens.isEmpty) {
    printInfo('No screens found to design goldens for in the active project.');
    return;
  }

  final screenOptions = screens
      .map((f) => p.basenameWithoutExtension(f.path))
      .toList();
  final choice = selectOption(
    'Select Screen to Design Golden',
    screenOptions,
    showBack: true,
  );

  if (choice == 'back' || choice == null) return;

  final index = int.tryParse(choice);
  if (index == null || index < 1 || index > screenOptions.length) {
    printError('Invalid selection.');
    return;
  }

  final screenName = screenOptions[index - 1];
  final screenNamePascal = _toPascalCase(screenName);

  printSection('Designing Golden: $screenNamePascal');

  await loadingSpinner(
    'Scaffolding visual regression test in $activePath',
    () async {
      final testPath = p.join(
        activePath,
        'test',
        'goldens',
        '${screenName}_golden_test.dart',
      );
      final testFile = File(testPath);

      if (!testFile.parent.existsSync()) {
        testFile.parent.createSync(recursive: true);
      }

      final content = getGoldenTestTemplate(
        projectName,
        screenNamePascal,
        screenName,
      );
      testFile.writeAsStringSync(content.trim() + '\n', mode: FileMode.write);
    },
  );

  printSuccess(
    'Golden test designed: test/goldens/${screenName}_golden_test.dart',
  );
  printInfo(
    '👉 Run "flutter test --update-goldens" to generate initial baselines.',
  );

  ask('Press Enter to return');
}

String _toPascalCase(String text) {
  return text
      .split('_')
      .map((s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1))
      .join();
}
