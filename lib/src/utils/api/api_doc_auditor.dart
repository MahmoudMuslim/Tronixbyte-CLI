import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runApiDocAudit() async {
  printSection('🛡️ API Documentation Auditor');

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    printError('lib directory not found.');
    return;
  }

  int undocumentedEndpoints = 0;
  final List<String> findings = [];

  await loadingSpinner('Auditing API documentation and annotations', () async {
    final files = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (f) =>
              (f.path.contains('api_service.dart') ||
                  f.path.contains('datasource.dart')) &&
              f.path.endsWith('.dart'),
        )
        .toList();

    for (final file in files) {
      final lines = file.readAsLinesSync();
      bool inClass = false;

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();

        if (line.contains('abstract class') || line.contains('class ')) {
          inClass = true;
          continue;
        }

        // Look for method definitions in API/DataSource classes
        if (inClass &&
            (line.startsWith('Future<') ||
                line.contains('GET(') ||
                line.contains('POST('))) {
          // Check if previous line is a comment or documentation
          bool hasDoc = false;
          if (i > 0) {
            final prevLine = lines[i - 1].trim();
            if (prevLine.startsWith('///') ||
                prevLine.startsWith('//') ||
                prevLine.contains('@Summary')) {
              hasDoc = true;
            }
          }

          if (!hasDoc) {
            final relPath = p.relative(file.path, from: Directory.current.path);
            findings.add(
              '❌ Undocumented endpoint in $relPath: "${line.split('(').first}"',
            );
            undocumentedEndpoints++;
          }
        }
      }
    }
  });

  if (undocumentedEndpoints == 0) {
    printSuccess(
      'API Documentation Audit Passed! All endpoints are documented.',
    );
  } else {
    print('\n$yellow${bold}DOCUMENTATION FINDINGS:$reset');
    for (var f in findings) {
      print('   $f');
    }
    printWarning(
      '\nAudit finished with $undocumentedEndpoints undocumented endpoints.',
    );
    printInfo(
      '👉 Tip: Use triple-slash (///) comments or Swagger annotations for better API clarity.',
    );
  }

  ask('Press Enter to return');
}
