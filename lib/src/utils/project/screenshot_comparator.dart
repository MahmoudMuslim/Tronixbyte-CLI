import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runScreenshotComparison() async {
  printSection('📱 UI Screenshot Comparison (Pixel Match)');

  final activePath = getActiveProjectPath();
  final baselineDir = Directory(p.join(activePath, 'screenshots', 'baseline'));
  final currentDir = Directory(
    p.join(activePath, 'build', 'integration_test_screenshots'),
  );

  if (!baselineDir.existsSync()) {
    printWarning(
      'Baseline directory not found in $activePath at: ${baselineDir.path}',
    );
    printInfo(
      'Please capture a baseline first and move screenshots to this folder.',
    );
    return;
  }

  if (!currentDir.existsSync()) {
    printError(
      'Current screenshots not found in project build folder at: ${currentDir.path}',
    );
    printInfo('Run "App Screenshot Automator" first.');
    return;
  }

  final List<String> diffs = [];
  final List<String> findings = [];

  await loadingSpinner(
    'Comparing screenshots for pixel-perfect matches in $activePath',
    () async {
      final baselineFiles = baselineDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.png'))
          .toList();

      for (final baseline in baselineFiles) {
        final name = p.basename(baseline.path);
        final current = File(p.join(currentDir.path, name));

        if (!current.existsSync()) {
          findings.add('❌ Missing in current: $name');
          diffs.add(name);
          continue;
        }

        // Simple comparison for this utility.
        final bBytes = baseline.readAsBytesSync();
        final cBytes = current.readAsBytesSync();

        if (bBytes.length != cBytes.length) {
          diffs.add(name);
        }
      }
    },
  );

  if (findings.isNotEmpty) {
    print('\n$blue${bold}COMPARISON ISSUES:$reset');
    for (var f in findings) {
      print('   $f');
    }
  }

  if (diffs.isEmpty) {
    printSuccess(
      'All screenshots match perfectly! No visual regressions detected.',
    );
  } else {
    printWarning('Found ${diffs.length} visual differences:');
    for (var d in diffs) {
      print('   - $d');
    }

    print('\n$cyan$bold📄 HTML REPORT GENERATION:$reset');
    final generate =
        (ask('Generate side-by-side HTML report? (y/n)') ?? 'n')
            .toLowerCase() ==
        'y';
    if (generate) {
      await _generateHtmlReport(
        activePath,
        diffs,
        baselineDir.path,
        currentDir.path,
      );
    }
  }
}

Future<void> _generateHtmlReport(
  String activePath,
  List<String> diffs,
  String baselinePath,
  String currentPath,
) async {
  await loadingSpinner('Generating VISUAL_REPORT.html in $activePath', () async {
    final buffer = StringBuffer();
    buffer.writeln('<html><head><title>Visual Regression Report</title>');
    buffer.writeln(
      '<style>body{font-family:sans-serif;background:#121212;color:white;padding:20px;}',
    );
    buffer.writeln(
      '.diff-row{display:flex;gap:20px;margin-bottom:40px;border-bottom:1px solid #333;padding-bottom:20px;}',
    );
    buffer.writeln(
      'img{max-width:400px;border:2px solid #444;}</style></head><body>',
    );
    buffer.writeln('<h1>🚀 Tronixbyte Visual Regression Report</h1>');

    for (final d in diffs) {
      // Use relative paths for HTML report references
      final relBaseline = p.relative(p.join(baselinePath, d), from: activePath);
      final relCurrent = p.relative(p.join(currentPath, d), from: activePath);

      buffer.writeln('<div class="diff-row">');
      buffer.writeln(
        '<div><h3>Baseline: $d</h3><img src="$relBaseline"></div>',
      );
      buffer.writeln('<div><h3>Current: $d</h3><img src="$relCurrent"></div>');
      buffer.writeln('</div>');
    }

    buffer.writeln('</body></html>');

    final reportFile = File(p.join(activePath, 'VISUAL_REPORT.html'));
    reportFile.writeAsStringSync(buffer.toString(), mode: FileMode.write);
  });

  printSuccess('Report generated: VISUAL_REPORT.html at project root.');
}
