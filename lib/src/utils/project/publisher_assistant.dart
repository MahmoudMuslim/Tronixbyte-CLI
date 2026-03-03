import 'package:tools/tools.dart';

Future<void> runPublisherAssistant() async {
  printSection('Package Publisher Assistant');

  int issues = 0;
  final List<String> findings = [];

  await loadingSpinner('Validating package for pub.dev publishing', () async {
    // 1. Validate pubspec.yaml
    final pubspecFile = File('pubspec.yaml');
    if (pubspecFile.existsSync()) {
      final content = pubspecFile.readAsStringSync();

      if (!content.contains('description:')) {
        findings.add('❌ Missing "description" in pubspec.yaml');
        issues++;
      } else {
        final descMatch = RegExp(r'description:\s*(.*)').firstMatch(content);
        if (descMatch != null && descMatch.group(1)!.trim().length < 60) {
          findings.add('⚠️ Description is too short (recommended > 60 chars)');
        }
      }

      if (!content.contains('repository:') && !content.contains('homepage:')) {
        findings.add('❌ Missing "repository" or "homepage" in pubspec.yaml');
        issues++;
      }

      if (!content.contains('version:')) {
        findings.add('❌ Missing "version" in pubspec.yaml');
        issues++;
      }
    } else {
      findings.add('❌ pubspec.yaml not found');
      issues++;
    }

    // 2. Check README.md
    final readme = File('README.md');
    if (!readme.existsSync() || readme.lengthSync() < 100) {
      findings.add('❌ README.md is missing or too short');
      issues++;
    }

    // 3. Check CHANGELOG.md
    final changelog = File('CHANGELOG.md');
    if (!changelog.existsSync() || changelog.lengthSync() < 50) {
      findings.add('❌ CHANGELOG.md is missing or too short');
      issues++;
    }

    // 4. Check LICENSE
    final license = File('LICENSE');
    if (!license.existsSync()) {
      findings.add('❌ LICENSE file is missing');
      issues++;
    }

    // 5. Dry-run publish
    printInfo('Running "dart pub publish --dry-run"...');
    final result = await Process.run('dart', ['pub', 'publish', '--dry-run']);
    if (result.exitCode != 0) {
      findings.add('❌ Dry-run failed:\n${result.stderr}');
      issues++;
    }
  });

  if (findings.isNotEmpty) {
    print('\n$blue${bold}PUBLISHING READINESS FINDINGS:$reset');
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
      await runCommand('dart', ['pub', 'publish']);
    }
  } else {
    printWarning('Found $issues issues that must be fixed before publishing.');
  }
}
