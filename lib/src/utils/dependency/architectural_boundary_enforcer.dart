import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> enforceArchitecturalBoundaries() async {
  printSection('🏛️ Architectural Boundary Enforcer');

  final activePath = getActiveProjectPath();
  final libDir = Directory(p.join(activePath, 'lib'));
  if (!libDir.existsSync()) {
    printError('lib directory not found.');
    return;
  }

  int violations = 0;
  final List<String> findings = [];

  await loadingSpinner(
    'Scanning for layer leakage and anti-patterns in $activePath',
    () async {
      final files = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) =>
                f.path.endsWith('.dart') &&
                !p.basename(f.path).startsWith('z_'),
          )
          .toList();

      for (final file in files) {
        final content = file.readAsStringSync();
        final relPath = p
            .relative(file.path, from: activePath)
            .replaceAll('\\', '/');

        // 1. Layer Boundary Check
        if (relPath.contains('/domain/')) {
          // Domain should not import Data or Presentation
          if (content.contains('/data/') ||
              content.contains('/presentation/')) {
            findings.add(
              '🚨 Domain Purity Violation: $relPath imports from Data or Presentation.',
            );
            violations++;
          }
        }

        if (relPath.contains('/presentation/')) {
          // Presentation should not import Data directly
          if (content.contains('/data/')) {
            findings.add(
              '🚨 Presentation Leakage: $relPath imports directly from Data layer.',
            );
            violations++;
          }
        }

        // 2. Fat Controller Check (UI Logic in BLoC/Managers)
        if (relPath.contains('/manager/') ||
            relPath.contains('/bloc/') ||
            relPath.contains('/cubit/')) {
          if (content.contains('MaterialApp') ||
              content.contains('Scaffold') ||
              content.contains('BuildContext')) {
            findings.add(
              '⚠️ Fat Controller Anti-pattern: $relPath contains UI-specific classes (BuildContext/Scaffold).',
            );
            violations++;
          }
        }

        // 3. Logic in Widgets
        if (relPath.contains('/widgets/')) {
          if (content.contains('Dio(') || content.contains('repository.get')) {
            findings.add(
              '⚠️ UI Logic Leakage: $relPath contains direct repository or network calls.',
            );
            violations++;
          }
        }
      }
    },
  );

  if (violations == 0) {
    printSuccess('Architectural boundaries are perfectly enforced!');
  } else {
    print('\n$red$bold🚨 ARCHITECTURAL VIOLATIONS DETECTED$reset');
    for (var f in findings) {
      print('   $f');
    }
    printWarning('\nFound $violations architectural boundary issues.');
    printInfo(
      '👉 Tip: Respect Clean Architecture layers to maintain scalability.',
    );
  }

  ask('Press Enter to return');
}
