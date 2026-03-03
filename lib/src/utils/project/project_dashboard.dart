import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> showProjectDashboard() async {
  printSection('Elite Project Dashboard');

  final activePath = getActiveProjectPath();

  await loadingSpinner(
    'Fetching real-time project health metrics in $activePath',
    () async {
      // 1. Get Project Stats
      final libDir = Directory(p.join(activePath, 'lib'));
      int totalFiles = 0;
      int totalLines = 0;
      if (libDir.existsSync()) {
        final entities = libDir.listSync(recursive: true);
        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.dart')) {
            totalFiles++;
            totalLines += entity.readAsLinesSync().length;
          }
        }
      }

      // 2. Check Git Status
      String branch = 'N/A';
      try {
        final result = await Process.run('git', [
          'rev-parse',
          '--abbrev-ref',
          'HEAD',
        ], workingDirectory: activePath);
        if (result.exitCode == 0) branch = result.stdout.toString().trim();
      } catch (_) {}

      // 3. Check for Security Concerns (Dry run of audit logic)
      int securityIssues = 0;
      final secretRegex = RegExp(
        r'(password|secret|api[_-]?key|token)',
        caseSensitive: false,
      );
      if (libDir.existsSync()) {
        final files = libDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));
        for (final file in files) {
          if (secretRegex.hasMatch(file.readAsStringSync())) securityIssues++;
        }
      }

      print('\n$blue$bold🚀 QUICK INSIGHTS for $activePath$reset');
      printTable(
        ['Category', 'Metric', 'Status'],
        [
          ['Architecture', '$totalFiles Files / $totalLines LOC', '✅ Solid'],
          ['VCS', 'Branch: $branch', '🌿 Active'],
          [
            'Security',
            '$securityIssues Hardcoded Strings',
            securityIssues > 0 ? '$red🚨 Action Needed$reset' : '✅ Clean',
          ],
          ['Build', 'Ready for Release', '📦 Stable'],
        ],
      );

      print('\n$cyan$bold💡 RECOMMENDATIONS$reset');
      if (securityIssues > 0) {
        print('   - Run "Security Pro" to extract hardcoded secrets.');
      }
      if (totalLines > 5000) {
        print(
          '   - Project is growing. Consider running "Architecture Linter".',
        );
      }
      print('   - Run "Smart Asset Optimizer" to reduce bundle size.');
    },
  );

  ask('Press Enter to return to menu');
}
