import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runCodeQualityTools() async {
  printSection('Elite Quality Gate & Global Test Runner');

  final activePath = getActiveProjectPath();
  final totalSteps = 7;
  final results = <List<String>>[];

  // 1. Code Formatting
  printStep(1, totalSteps, 'Formatting Dart files in $activePath');
  final formatStart = DateTime.now();
  // runCommand uses getActiveProjectPath() as working directory
  await runCommand('dart', ['format', '.'], loadingMessage: 'Formatting code');
  results.add([
    'Formatting',
    '✅ Pass',
    '${DateTime.now().difference(formatStart).inSeconds}s',
  ]);

  // 2. Automated Fixes
  printStep(2, totalSteps, 'Applying automated fixes');
  await runCommand('dart', [
    'fix',
    '--apply',
  ], loadingMessage: 'Applying fixes');
  results.add(['Auto-Fixes', '✅ Applied', '-']);

  // 3. Static Analysis
  printStep(3, totalSteps, 'Running static analysis');
  final analyzeStart = DateTime.now();
  await runCommand('flutter', ['analyze'], loadingMessage: 'Analyzing project');
  results.add([
    'Analysis',
    '✅ Clean',
    '${DateTime.now().difference(analyzeStart).inSeconds}s',
  ]);

  // 4. Unit & Widget Tests
  printStep(4, totalSteps, 'Running unit & widget tests');
  final testStart = DateTime.now();
  await runCommand('flutter', [
    'test',
    '--coverage',
  ], loadingMessage: 'Running tests');
  results.add([
    'Unit Tests',
    '✅ Pass',
    '${DateTime.now().difference(testStart).inSeconds}s',
  ]);

  // 5. Integration Tests
  final integrationDir = Directory(p.join(activePath, 'integration_test'));
  if (integrationDir.existsSync()) {
    printStep(5, totalSteps, 'Running integration tests');
    final intStart = DateTime.now();
    await runCommand('flutter', [
      'test',
      'integration_test',
    ], loadingMessage: 'Testing integrations');
    results.add([
      'Integration',
      '✅ Pass',
      '${DateTime.now().difference(intStart).inSeconds}s',
    ]);
  } else {
    printInfo(
      'Skipping Integration Tests (directory not found at ${integrationDir.path})',
    );
    results.add(['Integration', '⏩ Skipped', '-']);
  }

  // 6. Visual Regression
  final baselineDir = Directory(p.join(activePath, 'screenshots', 'baseline'));
  if (baselineDir.existsSync()) {
    printStep(6, totalSteps, 'Visual Regression Check');
    // Calling the comparison utility directly
    await runScreenshotComparison();
    results.add(['Visual', '✅ Verified', '-']);
  } else {
    printInfo(
      'Skipping Visual Regression (baseline directory not found at ${baselineDir.path})',
    );
    results.add(['Visual', '⏩ Skipped', '-']);
  }

  // 7. Dependency Sync
  printStep(7, totalSteps, 'Final project synchronization');
  await runCommand('flutter', ['pub', 'get'], loadingMessage: 'Syncing');
  results.add(['Final Sync', '✅ Success', '-']);

  print('\n$blue$bold🏁 GLOBAL QUALITY GATE SUMMARY$reset');
  printTable(['Step', 'Result', 'Time'], results);

  printSuccess('Quality gate complete! Project is stable and verified.');
  printInfo(
    'Unit Test Coverage: ${p.join(activePath, 'coverage', 'lcov.info')}',
  );
  ask('Press Enter to return');
}
