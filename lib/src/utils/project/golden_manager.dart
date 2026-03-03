import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runGoldenManager() async {
  printSection('🧪 Golden Test Manager');

  final activePath = getActiveProjectPath();
  final baselineDir = Directory(p.join(activePath, 'screenshots', 'baseline'));
  final currentDir = Directory(
    p.join(activePath, 'build', 'integration_test_screenshots'),
  );

  if (!baselineDir.existsSync()) {
    printWarning(
      'No baseline screenshots found in $activePath. Run a capture first.',
    );
    return;
  }

  if (!currentDir.existsSync()) {
    printError(
      'Current screenshots not found in project build folder. Run "App Screenshot Automator" first.',
    );
    return;
  }

  final List<String> diffs = [];
  final baselineFiles = baselineDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.png'))
      .toList();

  await loadingSpinner('Analyzing visual changes in $activePath', () async {
    for (final baseline in baselineFiles) {
      final name = p.basename(baseline.path);
      final current = File(p.join(currentDir.path, name));

      if (current.existsSync()) {
        final bBytes = baseline.readAsBytesSync();
        final cBytes = current.readAsBytesSync();
        if (bBytes.length != cBytes.length) {
          diffs.add(name);
        }
      }
    }
  });

  if (diffs.isEmpty) {
    printSuccess('No visual differences found. Baseline is up to date.');
    return;
  }

  printWarning('Detected ${diffs.length} visual changes that need review.');

  for (final diff in diffs) {
    print('\n$cyan${bold}REVIEWING: $diff$reset');
    print('   - Baseline: ${baselineDir.path}/$diff');
    print('   - Current:  ${currentDir.path}/$diff');

    final action = selectOption('Action for $diff', [
      'Approve (Set current as new baseline)',
      'Reject (Keep existing baseline)',
      'Skip for now',
    ], showBack: false);

    if (action == '1') {
      await loadingSpinner('Approving $diff', () async {
        final currentFile = File(p.join(currentDir.path, diff));
        final baselineFile = File(p.join(baselineDir.path, diff));
        baselineFile.writeAsBytesSync(currentFile.readAsBytesSync());
      });
      printSuccess('Updated baseline for $diff');
    } else if (action == '2') {
      printInfo('Rejected changes for $diff');
    }
  }

  printSuccess('Golden Test Management session complete!');
}
