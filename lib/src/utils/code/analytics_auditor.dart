import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runAnalyticsAudit() async {
  printSection('🧪 Behavioral Analytics Auditor');

  final activePath = getActiveProjectPath();
  final libDir = Directory(p.join(activePath, 'lib'));
  if (!libDir.existsSync()) {
    printError('lib directory not found at ${libDir.path}.');
    return;
  }

  int analyticsEvents = 0;
  final List<String> findings = [];

  // Regex for common analytics logging patterns (Firebase, Mixpanel, etc.)
  final eventRegex = RegExp(r'''\.logEvent\(name:\s*['"](\w+)['"]''');

  await loadingSpinner(
    'Auditing behavioral analytics tracking events in $activePath',
    () async {
      final files = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();

      for (final file in files) {
        final lines = file.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.startsWith('//')) continue;

          final match = eventRegex.firstMatch(line);
          if (match != null) {
            final eventName = match.group(1);
            final relPath = p.relative(file.path, from: activePath);
            findings.add('📈 Event "$eventName" tracked in $relPath:${i + 1}');
            analyticsEvents++;
          }
        }
      }
    },
  );

  if (analyticsEvents == 0) {
    printWarning(
      'No analytics events found. Ensure your features are being tracked.',
    );
  } else {
    print('\n$blue$bold🚀 REGISTERED ANALYTICS EVENTS$reset');
    for (var f in findings) {
      print('   $f');
    }
    printSuccess(
      '\nAudit complete! Found $analyticsEvents events across the project.',
    );
  }

  ask('Press Enter to return');
}
