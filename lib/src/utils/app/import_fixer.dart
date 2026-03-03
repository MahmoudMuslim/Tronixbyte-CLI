import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> fixRelativeImports() async {
  printSection('Package Import Fixer');

  final projectName = await getProjectName();
  final libDir = Directory('lib');

  if (!libDir.existsSync()) {
    printError('lib directory not found.');
    return;
  }

  int fixedFiles = 0;
  int totalFixes = 0;

  final files = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  await loadingSpinner(
    'Refactoring relative imports to package imports',
    () async {
      for (final file in files) {
        final lines = file.readAsLinesSync();
        bool fileChanged = false;
        final newLines = <String>[];

        for (var line in lines) {
          if (line.trim().startsWith('import ') &&
              line.contains("import '") &&
              !line.contains('package:')) {
            // Match relative imports like import '../...' or import './...'
            final match = RegExp(r"import\s+'(\.\.?\/[^']+)'").firstMatch(line);
            if (match != null) {
              final relativePath = match.group(1)!;
              final fileDir = p.dirname(file.path);
              final absoluteTarget = p.normalize(p.join(fileDir, relativePath));

              if (absoluteTarget.contains('lib${p.separator}')) {
                final packagePath = absoluteTarget
                    .split('lib${p.separator}')
                    .last
                    .replaceAll(p.separator, '/');
                final newLine = line.replaceFirst(
                  relativePath,
                  'package:$projectName/$packagePath',
                );
                newLines.add(newLine);
                fileChanged = true;
                totalFixes++;
                continue;
              }
            }
          }
          newLines.add(line);
        }

        if (fileChanged) {
          file.writeAsStringSync('${newLines.join('\n')}\n');
          fixedFiles++;
        }
      }
    },
  );

  if (fixedFiles > 0) {
    printSuccess('Fixed $totalFixes relative imports in $fixedFiles files.');
  } else {
    printInfo('No relative imports found. All clean!');
  }
}
