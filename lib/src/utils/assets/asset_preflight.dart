import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runAssetPreflight() async {
  printSection('📦 Production Asset Bundle (Pre-Flight)');

  final activePath = getActiveProjectPath();
  final assetsDir = Directory(p.join(activePath, 'assets'));
  if (!assetsDir.existsSync()) {
    printInfo('No assets directory found at ${assetsDir.path}.');
    return;
  }

  int jsonMinified = 0;
  int integrityIssues = 0;
  int optimizedSvgs = 0;

  await loadingSpinner(
    'Performing asset pre-flight checks in $activePath',
    () async {
      final entities = assetsDir.listSync(recursive: true);

      for (final entity in entities) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();

          // 1. Minify JSON
          if (ext == '.json') {
            try {
              final content = entity.readAsStringSync();
              final dynamic jsonObject = json.decode(content);
              final minified = json.encode(jsonObject);

              if (minified.length < content.length) {
                entity.writeAsStringSync(minified, mode: FileMode.write);
                jsonMinified++;
              }
            } catch (e) {
              printError(
                'Malformed JSON: ${p.relative(entity.path, from: activePath)}',
              );
              integrityIssues++;
            }
          }

          // 2. SVG Basic Integrity/Optimization Check
          if (ext == '.svg') {
            final content = entity.readAsStringSync();
            if (content.contains('<?xml') || content.contains('<!--')) {
              // Very basic "optimization" - stripping XML header and comments to save few bytes
              final cleaned = content
                  .replaceFirst(RegExp(r'<\?xml.*?\?>'), '')
                  .replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '')
                  .trim();
              if (cleaned.length < content.length) {
                entity.writeAsStringSync(cleaned, mode: FileMode.write);
                optimizedSvgs++;
              }
            }
          }
        }
      }

      // 3. Verify Pubspec Integrity
      final pubspec = File(p.join(activePath, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        final content = pubspec.readAsStringSync();
        final assetsMatch = RegExp(
          r'assets:\s*\n((?:\s+-\s+.*\n?)*)',
        ).firstMatch(content);
        if (assetsMatch != null) {
          final lines = assetsMatch.group(1)!.split('\n');
          for (var line in lines) {
            final trimmed = line.trim().replaceFirst('- ', '').trim();
            if (trimmed.isEmpty) continue;

            // Check if path exists relative to active project root
            final absoluteAssetPath = p.normalize(p.join(activePath, trimmed));

            if (trimmed.endsWith('/')) {
              if (!Directory(absoluteAssetPath).existsSync()) {
                printWarning(
                  'Asset directory in pubspec does not exist: $trimmed',
                );
                integrityIssues++;
              }
            } else {
              if (!File(absoluteAssetPath).existsSync()) {
                printWarning('Asset file in pubspec does not exist: $trimmed');
                integrityIssues++;
              }
            }
          }
        }
      }
    },
  );

  print('\n$blue$bold📊 PRE-FLIGHT SUMMARY$reset');
  printTable(
    ['Check', 'Result'],
    [
      ['JSON Minified', jsonMinified.toString()],
      ['SVGs Optimized', optimizedSvgs.toString()],
      ['Integrity Issues', integrityIssues.toString()],
    ],
  );

  if (integrityIssues == 0) {
    printSuccess('Asset bundle is healthy and ready for production!');
  } else {
    printWarning(
      'Found $integrityIssues integrity issues. Please review before release.',
    );
  }
}
