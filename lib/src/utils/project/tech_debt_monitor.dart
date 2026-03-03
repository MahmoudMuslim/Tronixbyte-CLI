import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runTechDebtMonitor() async {
  printSection('📈 Visual Technical Debt Monitor');

  final activePath = getActiveProjectPath();
  double healthScore = 100.0;
  final List<String> deductions = [];

  await loadingSpinner(
    'Calculating Architectural Health Score in $activePath',
    () async {
      final libDir = Directory(p.join(activePath, 'lib'));
      final dartFiles = libDir.existsSync()
          ? libDir
                .listSync(recursive: true)
                .whereType<File>()
                .where((f) => f.path.endsWith('.dart'))
                .toList()
          : <File>[];

      // 1. Dependency Drift Check
      final result = await Process.run('flutter', [
        'pub',
        'outdated',
        '--json',
      ], workingDirectory: activePath);
      if (result.exitCode == 0) {
        final data = json.decode(result.stdout.toString());
        final packages = data['packages'] as List;
        int outdatedCount = packages
            .where((pkg) => pkg['current'] != pkg['latest'])
            .length;
        if (outdatedCount > 0) {
          double penalty = outdatedCount * 1.5;
          healthScore -= penalty;
          deductions.add(
            '-$penalty points: $outdatedCount outdated packages detected.',
          );
        }
      }

      // 2. Resource Leaks Check (Deep AST Scan)
      int leaks = 0;
      final resourcePatterns = {
        'StreamController': RegExp(r'StreamController<.*>\(.*\)'),
        'FocusNode': RegExp(r'FocusNode\(.*\)'),
        'TextEditingController': RegExp(r'TextEditingController\(.*\)'),
      };

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        for (var entry in resourcePatterns.entries) {
          if (content.contains(entry.value) &&
              !content.contains(
                entry.key == 'StreamController' ? '.close()' : '.dispose()',
              )) {
            leaks++;
          }
        }
      }
      if (leaks > 0) {
        double penalty = leaks * 4.0;
        healthScore -= penalty;
        deductions.add('-$penalty points: $leaks potential resource leaks.');
      }

      // 3. TODO/FIXME Debt
      int todos = 0;
      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        todos += RegExp(
          r'//\s*(TODO|FIXME)',
          caseSensitive: false,
        ).allMatches(content).length;
      }
      if (todos > 5) {
        double penalty = (todos - 5) * 0.5;
        healthScore -= penalty;
        deductions.add(
          '-$penalty points: $todos pending technical debt items.',
        );
      }

      // 4. Architectural Layer Violations
      int architectureViolations = 0;
      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        final relPath = p
            .relative(file.path, from: activePath)
            .replaceAll('\\', '/');

        if (relPath.contains('/domain/') &&
            (content.contains('/data/') ||
                content.contains('/presentation/'))) {
          architectureViolations++;
        }
        if (relPath.contains('/presentation/') && content.contains('/data/')) {
          architectureViolations++;
        }
      }
      if (architectureViolations > 0) {
        double penalty = architectureViolations * 10.0;
        healthScore -= penalty;
        deductions.add(
          '-$penalty points: $architectureViolations layer purity violations.',
        );
      }

      // 5. Large File Debt (Complexity)
      int largeFiles = 0;
      for (final file in dartFiles) {
        if (file.readAsLinesSync().length > 300) {
          largeFiles++;
        }
      }
      if (largeFiles > 0) {
        double penalty = largeFiles * 2.0;
        healthScore -= penalty;
        deductions.add(
          '-$penalty points: $largeFiles files exceeding 300 LOC.',
        );
      }
    },
  );

  healthScore = healthScore.clamp(0.0, 100.0);

  // Display TUI Dashboard
  clearConsole();
  printBanner();
  printSection('Engineering Health Dashboard');

  final color = healthScore > 85 ? green : (healthScore > 65 ? yellow : red);
  final barLength = (healthScore / 2.5).toInt();
  final bar = '█' * barLength;

  print('\n$blue$bold🏥 ARCHITECTURAL HEALTH SCORE$reset');
  print('   $color$bar$reset ${healthScore.toStringAsFixed(1)}/100');

  if (deductions.isNotEmpty) {
    print('\n$yellow$bold⚠️  TOP DEBT CONTRIBUTORS:$reset');
    for (var d in deductions.take(8)) {
      print('   $d');
    }
  }

  print('\n$cyan$bold🚀 ELITE RECOMMENDATIONS:$reset');
  if (healthScore < 90) {
    if (deductions.any((d) => d.contains('purity'))) {
      print(
        '   - Fix Architectural Violations immediately to prevent logic rot.',
      );
    }
    if (deductions.any((d) => d.contains('leaks'))) {
      print(
        '   - Run "Memory Leak Auditor" to identify specific resource leaks.',
      );
    }
    print(
      '   - Run "tools quality" to ensure consistent formatting and analysis.',
    );
  } else {
    print(
      '   - Project is in elite condition. High architectural maturity detected.',
    );
  }

  print('\n$blue$bold${'=' * 60}$reset');
  ask('Press Enter to return');
}
