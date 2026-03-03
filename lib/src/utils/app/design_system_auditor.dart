import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runDesignSystemAudit() async {
  printSection('🛡️ Design System Auditor');

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    printError('lib directory not found.');
    return;
  }

  int violations = 0;
  final List<String> findings = [];

  // Regex for hardcoded colors (hex or static Colors.name)
  final colorRegex = RegExp(r'(Colors\.[a-z]+|Color\(0x[0-9a-fA-F]{8}\))');

  await loadingSpinner(
    'Auditing UI components for Design System consistency',
    () async {
      final files = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) =>
                (f.path.contains('/widgets/') ||
                    f.path.contains('/screens/')) &&
                f.path.endsWith('.dart'),
          )
          .toList();

      for (final file in files) {
        final lines = file.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.startsWith('//')) continue; // Skip comments

          final match = colorRegex.firstMatch(line);
          if (match != null) {
            final relPath = p.relative(file.path, from: Directory.current.path);
            findings.add(
              '⚠️ Hardcoded color "${match.group(0)}" in $relPath:${i + 1}',
            );
            violations++;
          }
        }
      }
    },
  );

  if (violations == 0) {
    printSuccess(
      'Design System Audit Passed! Your UI is consistent with theme variables.',
    );
  } else {
    print('\n$yellow${bold}CONSISTENCY FINDINGS:$reset');
    for (var f in findings) {
      print('   $f');
    }
    printWarning('\nAudit finished with $violations hardcoded color usages.');
    printInfo(
      '👉 Recommendation: Use "context.colorScheme.primary" or "AppColors" for better Material 3 consistency.',
    );
  }

  ask('Press Enter to return');
}
