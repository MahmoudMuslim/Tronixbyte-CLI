import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runTestSuiteGenerator() async {
  printSection('Advanced Test Suite Generator');

  final projectName = await getProjectName();
  final featuresDir = Directory('lib/features');

  if (!featuresDir.existsSync()) {
    printError('lib/features directory not found.');
    return;
  }

  final options = [
    'Generate Widget Tests for all Screens',
    'Scaffold Golden Tests (Visual Regression)',
    'Generate Feature Integration Test Templates',
  ];

  final choice = selectOption('Testing Options', options, showBack: true);
  if (choice == 'back' || choice == null) return;

  await loadingSpinner('Generating Elite Test Suite', () async {
    switch (choice) {
      case '1':
        await _generateWidgetTests(featuresDir, projectName);
        break;
      case '2':
        await _scaffoldGoldenTests();
        break;
      case '3':
        await _generateIntegrationTemplates(featuresDir, projectName);
        break;
    }
  });

  printSuccess('Test suite generation complete!');
}

Future<void> _generateWidgetTests(
  Directory featuresDir,
  String projectName,
) async {
  final screens = featuresDir
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (f) =>
            f.path.contains('presentation/screens') && f.path.endsWith('.dart'),
      )
      .toList();

  for (final file in screens) {
    final fileName = p.basenameWithoutExtension(file.path);
    final className = _toPascalCase(fileName);
    final testPath = p.join(
      'test',
      'features',
      p.basename(p.dirname(p.dirname(p.dirname(file.path)))),
      'presentation',
      '${fileName}_test.dart',
    );

    final testFile = File(testPath);
    if (testFile.existsSync()) continue;

    if (!testFile.parent.existsSync()) {
      testFile.parent.createSync(recursive: true);
    }

    final content = getWidgetTestsTemplate(projectName, className);
    testFile.writeAsStringSync(content.trim(), mode: FileMode.write);
    printInfo('Scaffolded Widget Test: $testPath');
  }
}

Future<void> _scaffoldGoldenTests() async {
  await runCommand('flutter', ['pub', 'add', 'dev:alchemist']);

  final goldenDir = Directory('test/goldens');
  if (!goldenDir.existsSync()) goldenDir.createSync(recursive: true);

  final readme = File('test/goldens/README.md');
  readme.writeAsStringSync(
    getScaffoldGoldenTestsTemplate(),
    mode: FileMode.write,
  );

  printInfo('Golden test infrastructure configured with "alchemist".');
}

Future<void> _generateIntegrationTemplates(
  Directory featuresDir,
  String projectName,
) async {
  final features = featuresDir.listSync().whereType<Directory>().toList();

  for (final feature in features) {
    final name = p.basename(feature.path);
    if (name.startsWith('z_')) continue;

    final testPath = p.join('integration_test', '${name}_flow_test.dart');
    final testFile = File(testPath);
    if (testFile.existsSync()) continue;

    if (!testFile.parent.existsSync()) {
      testFile.parent.createSync(recursive: true);
    }

    final content = getGenerateIntegrationTemplate(name, projectName);
    testFile.writeAsStringSync(content.trim(), mode: FileMode.write);
    printInfo('Scaffolded Integration Template: $testPath');
  }
}

String _toPascalCase(String text) {
  return text.split('_').map((s) => s[0].toUpperCase() + s.substring(1)).join();
}
