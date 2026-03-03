import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runStoreMetadataAudit() async {
  printSection('📱 Automated Store Metadata Auditor');

  final activePath = getActiveProjectPath();
  final androidPath = p.join(activePath, 'android/fastlane/metadata/android');
  final iosPath = p.join(activePath, 'ios/fastlane/metadata');

  int issues = 0;
  final List<String> findings = [];

  await loadingSpinner(
    'Auditing local store metadata and assets in $activePath',
    () async {
      // 1. Check for basic metadata structure
      if (!Directory(p.join(activePath, 'fastlane')).existsSync()) {
        findings.add(
          '❌ fastlane/ directory not found. Store automation might be missing.',
        );
        issues++;
      }

      // 2. Android Metadata Check
      final androidDir = Directory(androidPath);
      if (androidDir.existsSync()) {
        final languages = androidDir.listSync().whereType<Directory>();
        for (final lang in languages) {
          final langCode = p.basename(lang.path);
          final title = File(p.join(lang.path, 'title.txt'));
          if (!title.existsSync() || title.readAsStringSync().trim().isEmpty) {
            findings.add('⚠️ Android ($langCode): Missing or empty title.txt');
          } else if (title.readAsStringSync().length > 50) {
            findings.add(
              '❌ Android ($langCode): title.txt exceeds 50 characters.',
            );
            issues++;
          }

          final shortDesc = File(p.join(lang.path, 'short_description.txt'));
          if (!shortDesc.existsSync() ||
              shortDesc.readAsStringSync().length > 80) {
            findings.add(
              '❌ Android ($langCode): short_description.txt missing or > 80 chars.',
            );
            issues++;
          }
        }
      }

      // 3. iOS Metadata Check
      final iosDir = Directory(iosPath);
      if (iosDir.existsSync()) {
        final languages = iosDir.listSync().whereType<Directory>();
        for (final lang in languages) {
          final langCode = p.basename(lang.path);
          final name = File(p.join(lang.path, 'name.txt'));
          if (!name.existsSync() || name.readAsStringSync().length > 30) {
            findings.add('❌ iOS ($langCode): name.txt missing or > 30 chars.');
            issues++;
          }
        }
      }

      // 4. Screenshot Completeness
      final screenshotsDir = Directory(p.join(activePath, 'screenshots'));
      if (screenshotsDir.existsSync()) {
        final files = screenshotsDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.png'));
        if (files.length < 2) {
          findings.add(
            '⚠️ Screenshots folder has very few images. App stores usually require 2-8.',
          );
        }
      } else {
        findings.add('❌ screenshots/ directory not found.');
        issues++;
      }
    },
  );

  if (findings.isEmpty) {
    printSuccess('Store metadata appears to be compliant and synchronized!');
  } else {
    print('\n$yellow${bold}METADATA FINDINGS:$reset');
    for (var f in findings) {
      print('   $f');
    }
    printWarning('\nAudit finished with $issues critical compliance issues.');
    printInfo(
      '👉 Tip: Use Fastlane to automate metadata uploads to Google Play and App Store.',
    );
  }

  ask('Press Enter to return');
}
