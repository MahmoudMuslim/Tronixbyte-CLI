import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runGoldenDesigner() async {
  printSection('🧪 Golden Test Designer');

  final projectName = await getProjectName();
  final featuresDir = Directory('lib/features');

  if (!featuresDir.existsSync()) {
    printError('lib/features directory not found.');
    return;
  }

  printInfo(
    'This tool will help you design visual expectations for your screens.',
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
    printInfo('No screens found to design goldens for.');
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

  final index = int.parse(choice) - 1;
  final screenName = screenOptions[index];
  final screenNamePascal = _toPascalCase(screenName);

  printSection('Designing Golden: $screenNamePascal');

  await loadingSpinner('Scaffolding visual regression test', () async {
    final testPath = p.join(
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
    testFile.writeAsStringSync(content.trim(), mode: FileMode.write);
  });

  printSuccess(
    'Golden test designed: test/goldens/${screenName}_golden_test.dart',
  );
  printInfo(
    '👉 Run "flutter test --update-goldens" to generate initial baselines.',
  );

  ask('Press Enter to return');
}

String _toPascalCase(String text) {
  return text.split('_').map((s) => s[0].toUpperCase() + s.substring(1)).join();
}
