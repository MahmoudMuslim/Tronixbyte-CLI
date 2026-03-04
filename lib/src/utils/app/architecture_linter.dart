import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> checkArchitecture() async {
  printSection('Clean Architecture Linter');

  final activePath = getActiveProjectPath();
  final featuresDir = Directory(p.join(activePath, 'lib', 'features'));

  if (!featuresDir.existsSync()) {
    printWarning(
      'lib/features directory not found in the active project. Skipping architecture check.',
    );
    return;
  }

  int issues = 0;
  final List<Map<String, dynamic>> violations = [];

  void reportSmell(
    String feature,
    String layer,
    String filePath,
    String message, {
    String? offendingLine,
    File? fileObj,
  }) {
    print('   $red$bold🚨 [Smell] $feature -> $layer:$reset $message');
    print('      ${cyan}File:$reset ${p.relative(filePath, from: activePath)}');
    if (offendingLine != null) {
      print('      ${yellow}Line:$reset ${offendingLine.trim()}');
    }
    issues++;
    if (fileObj != null && offendingLine != null) {
      violations.add({
        'file': fileObj,
        'line': offendingLine,
        'feature': feature,
        'layer': layer,
      });
    }
  }

  final features = featuresDir.listSync().whereType<Directory>();

  await loadingSpinner(
    'Analyzing architectural layers for decoupling in $activePath',
    () async {
      for (final feature in features) {
        final name = p.basename(feature.path);
        if (name.startsWith('z_')) continue;

        // 1. Check Domain Layer (Should not import Data or Presentation)
        final domainDir = Directory(p.join(feature.path, 'domain'));
        if (domainDir.existsSync()) {
          final files = domainDir
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'));
          for (final file in files) {
            final lines = file.readAsLinesSync();
            for (final line in lines) {
              if (line.trim().startsWith('import ')) {
                if (line.contains('/data/') ||
                    line.contains('/presentation/')) {
                  reportSmell(
                    name,
                    'Domain',
                    file.path,
                    'Illegal dependency on Data or Presentation layer.',
                    offendingLine: line,
                    fileObj: file,
                  );
                }
              }
            }
          }
        }

        // 2. Check Presentation Layer (Should not import Data)
        final presentationDir = Directory(p.join(feature.path, 'presentation'));
        if (presentationDir.existsSync()) {
          final files = presentationDir
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'));
          for (final file in files) {
            final lines = file.readAsLinesSync();
            for (final line in lines) {
              if (line.trim().startsWith('import ')) {
                if (line.contains('/data/')) {
                  reportSmell(
                    name,
                    'Presentation',
                    file.path,
                    'Direct dependency on Data layer detected.',
                    offendingLine: line,
                    fileObj: file,
                  );
                }
              }
            }
          }
        }

        // 3. Check for Models in Domain (Should use Entities)
        if (domainDir.existsSync()) {
          final files = domainDir
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'));
          for (final file in files) {
            final content = file.readAsStringSync();
            if (content.contains('Model')) {
              reportSmell(
                name,
                'Domain',
                file.path,
                'Domain layer should use Entities, not Models.',
              );
            }
          }
        }
      }
    },
  );

  if (issues == 0) {
    printSuccess('Architecture looks solid! No smells detected.');
  } else {
    print('\n');
    printWarning('Total Architectural Issues Found: $issues');

    if (violations.isNotEmpty) {
      print('\n$cyan$bold🛠️  ARCHITECTURAL HEALING AVAILABLE:$reset');
      printInfo(
        'The CLI can attempt to comment out illegal imports to restore layer isolation.',
      );

      final fix =
          (ask(
                    'Would you like to auto-heal these $issues violations? (y/n)',
                    defaultValue: 'n',
                  ) ??
                  'n')
              .toLowerCase() ==
          'y';
      if (fix) {
        await loadingSpinner('Restoring layer isolation', () async {
          for (final v in violations) {
            final File file = v['file'];
            final String offendingLine = v['line'];
            String content = file.readAsStringSync();
            content = content.replaceFirst(
              offendingLine,
              '// FIXED BY CLI: $offendingLine',
            );
            file.writeAsStringSync(content);
          }
        });
        printSuccess(
          'Self-healing complete. Please review the commented imports.',
        );
      }
    }
  }
}
