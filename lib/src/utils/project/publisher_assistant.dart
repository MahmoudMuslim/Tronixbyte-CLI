import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runPublisherAssistant() async {
  printSection('Package Publisher Assistant');

  final activePath = getActiveProjectPath();
  int issues = 0;
  final List<String> findings = [];

  await loadingSpinner(
    'Validating package for pub.dev publishing in $activePath',
    () async {
      // 1. Validate pubspec.yaml
      final pubspecFile = File(p.join(activePath, 'pubspec.yaml'));
      if (pubspecFile.existsSync()) {
        final content = pubspecFile.readAsStringSync();

        if (!content.contains('description:')) {
          findings.add('❌ Missing "description" in pubspec.yaml');
          issues++;
        } else {
          final descMatch = RegExp(r'description:\s*(.*)').firstMatch(content);
          if (descMatch != null && descMatch.group(1)!.trim().length < 60) {
            findings.add(
              '⚠️ Description is too short (recommended > 60 chars)',
            );
          }
        }

        if (!content.contains('repository:') &&
            !content.contains('homepage:')) {
          findings.add('❌ Missing "repository" or "homepage" in pubspec.yaml');
          issues++;
        }

        if (!content.contains('version:')) {
          findings.add('❌ Missing "version" in pubspec.yaml');
          issues++;
        }
      } else {
        findings.add('❌ pubspec.yaml not found at ${pubspecFile.path}');
        issues++;
      }

      // 2. Check README.md
      final readme = File(p.join(activePath, 'README.md'));
      if (!readme.existsSync() || readme.lengthSync() < 100) {
        findings.add('❌ README.md is missing or too short');
        issues++;
      }

      // 3. Check CHANGELOG.md
      final changelog = File(p.join(activePath, 'CHANGELOG.md'));
      if (!changelog.existsSync() || changelog.lengthSync() < 50) {
        findings.add('❌ CHANGELOG.md is missing or too short');
        issues++;
      }

      // 4. Check LICENSE
      final license = File(p.join(activePath, 'LICENSE'));
      if (!license.existsSync()) {
        findings.add('❌ LICENSE file is missing');
        issues++;
      }

      // 5. Dry-run publish
      printInfo('Running "dart pub publish --dry-run" in $activePath...');
      final result = await Process.run('dart', [
        'pub',
        'publish',
        '--dry-run',
      ], workingDirectory: activePath);
      if (result.exitCode != 0) {
        findings.add('❌ Dry-run failed:\n${result.stderr}');
        issues++;
      }
    },
  );

  if (findings.isNotEmpty) {
    print('\n$blue${bold}PUBLISHING READINESS FINDINGS for $activePath:$reset');
    for (var f in findings) {
      print('   $f');
    }
  }

  print('\n$blue$bold${'=' * 60}$reset');
  if (issues == 0) {
    printSuccess('Your package is READY for pub.dev!');
    final proceed =
        (ask('Would you like to publish now? (y/n)') ?? 'n').toLowerCase() ==
        'y';
    if (proceed) {
      // runCommand uses getActiveProjectPath() internally
      await runCommand('dart', ['pub', 'publish']);
    }
  } else {
    printWarning('Found $issues issues that must be fixed before publishing.');
  }
}
