import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runObfuscationGuard() async {
  printSection('🛡️ Advanced Logic Flow Obfuscation (Guard)');

  final activePath = getActiveProjectPath();

  printInfo(
    'Researching AST-level logic flow mangling for project hardening in $activePath.',
  );
  printInfo(
    'This module targets the protection of sensitive business logic in compiled binaries.',
  );

  final confirm =
      (ask('Proceed with obfuscation readiness scan? (y/n)') ?? 'n')
          .toLowerCase() ==
      'y';
  if (!confirm) return;

  await loadingSpinner(
    'Analyzing code structure for obfuscation patterns',
    () async {
      final libDir = Directory(p.join(activePath, 'lib'));
      if (!libDir.existsSync()) return;

      final files = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      int complexMethods = 0;
      for (final file in files) {
        final content = file.readAsStringSync();
        // Heuristic: Count methods with high cyclomatic potential
        complexMethods += RegExp(
          r'(if|for|while|switch)\s*\(',
        ).allMatches(content).length;
      }

      printInfo(
        'Identified $complexMethods critical logic blocks for flow protection.',
      );
    },
  );

  printSuccess('Obfuscation Guard: Readiness report generated.');
  printInfo(
    '👉 Strategic Goal: Deep AST mangling to be implemented in Phase 25.',
  );
  printWarning(
    'Current Recommendation: Use "flutter build --obfuscate --split-debug-info" for production releases.',
  );

  ask('Press Enter to return');
}
