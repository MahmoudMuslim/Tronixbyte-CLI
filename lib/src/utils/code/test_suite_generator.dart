import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runTestSuiteGenerator() async {
  printSection('🧪 Advanced Test Suite Generator');

  final activePath = getActiveProjectPath();
  final projectName = await getProjectName();
  final featuresDir = Directory(p.join(activePath, 'lib', 'features'));

  if (!featuresDir.existsSync()) {
    printError('lib/features directory not found.');
    return;
  }

  final features = featuresDir.listSync().whereType<Directory>();
  if (features.isEmpty) {
    printWarning('No features found to generate tests for.');
    return;
  }

  await loadingSpinner(
    'Scaffolding multi-platform test suites in $activePath',
    () async {
      for (final featureDir in features) {
        final featureName = p.basename(featureDir.path);
        if (featureName.startsWith('z_')) continue;

        final namePascal =
            featureName[0].toUpperCase() + featureName.substring(1);
        final testBaseDir = Directory(
          p.join(activePath, 'test', 'features', featureName),
        );
        if (!testBaseDir.existsSync()) testBaseDir.createSync(recursive: true);

        // 1. Widget Test Scaffolding
        final screensDir = Directory(
          p.join(featureDir.path, 'presentation', 'screens'),
        );
        if (screensDir.existsSync()) {
          final screens = screensDir.listSync().whereType<File>().where(
            (f) =>
                f.path.endsWith('.dart') &&
                !p.basename(f.path).startsWith('z_'),
          );
          for (final screen in screens) {
            final screenName = p.basenameWithoutExtension(screen.path);
            final testFile = File(
              p.join(testBaseDir.path, '${screenName}_test.dart'),
            );
            if (!testFile.existsSync()) {
              testFile.writeAsStringSync(
                getWidgetTestTemplate(projectName, namePascal),
              );
            }
          }
        }

        // 2. Golden Test Setup (Visual Regression)
        final goldenFile = File(
          p.join(testBaseDir.path, '${featureName}_golden_test.dart'),
        );
        if (!goldenFile.existsSync()) {
          goldenFile.writeAsStringSync(
            getGoldenTestTemplate(projectName, namePascal, featureName),
          );
        }

        // 3. Integration Test Stub
        final integrationDir = Directory(
          p.join(activePath, 'integration_test', featureName),
        );
        if (!integrationDir.existsSync()) {
          integrationDir.createSync(recursive: true);
        }
        final integrationFile = File(
          p.join(integrationDir.path, '${featureName}_flow_test.dart'),
        );
        if (!integrationFile.existsSync()) {
          integrationFile.writeAsStringSync("""
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:$projectName/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End: $namePascal Flow', () {
    testWidgets('Verify complete $featureName journey', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      // TODO: Implement interaction flow
    });
  });
}
""");
        }
      }
    },
  );

  printSuccess('Advanced test suites scaffolded for all features.');
  printInfo(
    '👉 Check the "test/features/" and "integration_test/" directories.',
  );
  ask('Press Enter to return');
}
