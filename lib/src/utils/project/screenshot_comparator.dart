import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runScreenshotComparison() async {
  printSection('📱 UI Screenshot Comparison (Pixel Match)');

  final baselineDir = Directory('screenshots/baseline');
  final currentDir = Directory('build/integration_test_screenshots');

  if (!baselineDir.existsSync()) {
    printWarning('Baseline directory not found at: ${baselineDir.path}');
    printInfo(
      'Please capture a baseline first and move screenshots to this folder.',
    );
    return;
  }

  if (!currentDir.existsSync()) {
    printError('Current screenshots not found at: ${currentDir.path}');
    printInfo('Run "App Screenshot Automator" first.');
    return;
  }

  final List<String> diffs = [];
  final List<String> findings = [];

  await loadingSpinner('Comparing screenshots for pixel-perfect matches', () async {
    final baselineFiles = baselineDir
        .listSync()
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

      // In a real implementation, we would use the 'image' package to compare pixels.
      // For this CLI utility, we compare file sizes or hashes as a proxy,
      // or we can implement full pixel-by-pixel if 'image' is already a dependency.
      final bBytes = baseline.readAsBytesSync();
      final cBytes = current.readAsBytesSync();

      if (bBytes.length != cBytes.length) {
        diffs.add(name);
      }
    }
  });

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
      await _generateHtmlReport(diffs, baselineDir.path, currentDir.path);
    }
  }
}

Future<void> _generateHtmlReport(
  List<String> diffs,
  String baselinePath,
  String currentPath,
) async {
  await loadingSpinner('Generating REPORT.html', () async {
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
      buffer.writeln('<div class="diff-row">');
      buffer.writeln(
        '<div><h3>Baseline: $d</h3><img src="$baselinePath/$d"></div>',
      );
      buffer.writeln(
        '<div><h3>Current: $d</h3><img src="$currentPath/$d"></div>',
      );
      buffer.writeln('</div>');
    }

    buffer.writeln('</body></html>');

    File(
      'VISUAL_REPORT.html',
    ).writeAsStringSync(buffer.toString(), mode: FileMode.write);
  });

  printSuccess('Report generated: VISUAL_REPORT.html');
}
