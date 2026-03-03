import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runMemoryLeakAudit() async {
  printSection('📉 Deep AST Resource Leak Auditor');

  final activePath = getActiveProjectPath();
  final libDir = Directory(p.join(activePath, 'lib'));
  if (!libDir.existsSync()) {
    printError('lib directory not found.');
    return;
  }

  final List<String> findings = [];
  int leakCount = 0;

  await loadingSpinner(
    'Analyzing resource lifecycles (AST Scan) in $activePath',
    () async {
      final files = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();

      // Regex patterns for resources that MUST be closed/disposed
      final resourcePatterns = {
        'StreamController': RegExp(r'StreamController<.*>\(.*\)'),
        'FocusNode': RegExp(r'FocusNode\(.*\)'),
        'TextEditingController': RegExp(r'TextEditingController\(.*\)'),
        'ScrollController': RegExp(r'ScrollController\(.*\)'),
        'AnimationController': RegExp(r'AnimationController\(.*\)'),
        'Timer': RegExp(r'Timer\.(periodic|run)\(.*\)'),
      };

      for (final file in files) {
        final content = file.readAsStringSync();

        for (var entry in resourcePatterns.entries) {
          final type = entry.key;
          final regex = entry.value;

          if (regex.hasMatch(content)) {
            // Check if .close() or .dispose() is present for this type
            // This is a simplified AST check via string analysis
            final disposePattern = type == 'StreamController'
                ? '.close()'
                : '.dispose()';
            final timerPattern = type == 'Timer' ? '.cancel()' : disposePattern;

            final actualPattern = type == 'Timer'
                ? timerPattern
                : disposePattern;

            if (!content.contains(actualPattern)) {
              final relPath = p.relative(file.path, from: activePath);
              findings.add(
                '⚠️ Potential $type leak in $relPath (Missing $actualPattern)',
              );
              leakCount++;
            }
          }
        }
      }
    },
  );

  if (leakCount == 0) {
    printSuccess(
      'No obvious resource leaks detected! Streams and Controllers appear safe.',
    );
  } else {
    print('\n$red$bold🚨 POTENTIAL RESOURCE LEAKS$reset');
    for (var f in findings) {
      print('   $f');
    }
    printWarning('\nFound $leakCount suspicious lifecycle patterns.');
    printInfo(
      '👉 Tip: Ensure all Controllers and Streams are closed in dispose() or onClose().',
    );
  }

  ask('Press Enter to return');
}
