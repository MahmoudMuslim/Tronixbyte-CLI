import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runMonorepoDependencyGraph() async {
  printSection('📦 Multi-Repo Dependency Graph');

  final activePath = getActiveProjectPath();
  final packagesDir = Directory(p.join(activePath, 'packages'));

  if (!packagesDir.existsSync()) {
    printError('No "packages/" directory found at ${packagesDir.path}.');
    return;
  }

  final StringBuffer dotBuffer = StringBuffer();
  dotBuffer.writeln('digraph G {');
  dotBuffer.writeln('  rankdir=LR;');
  dotBuffer.writeln('  node [shape=box, style=filled, color=lightgreen];');

  final List<String> connections = [];
  final List<Directory> packages = packagesDir
      .listSync()
      .whereType<Directory>()
      .toList();

  await loadingSpinner(
    'Analyzing internal package dependencies in $activePath',
    () async {
      for (final pkgDir in packages) {
        final pubspecFile = File(p.join(pkgDir.path, 'pubspec.yaml'));
        if (!pubspecFile.existsSync()) continue;

        final pkgName = p.basename(pkgDir.path);
        final content = pubspecFile.readAsStringSync();

        // Look for path dependencies:
        // name:
        //   path: ../other_pkg
        final pathDepRegex = RegExp(
          r'^\s+(\w+):\s*\n\s+path:\s+\.\./(\w+)',
          multiLine: true,
        );
        final matches = pathDepRegex.allMatches(content);

        for (final match in matches) {
          final depName = match.group(1);
          if (depName != null) {
            connections.add('  "$pkgName" -> "$depName";');
          }
        }
      }
    },
  );

  if (connections.isEmpty) {
    printInfo('No internal dependencies found between packages.');
  } else {
    for (final conn in connections) {
      dotBuffer.writeln(conn);
    }
  }

  dotBuffer.writeln('}');

  final dotFileName = 'MONOREPO_ARCHITECTURE.dot';
  final dotFile = File(p.join(activePath, dotFileName));
  dotFile.writeAsStringSync(dotBuffer.toString(), mode: FileMode.write);

  printSuccess(
    'Graphviz DOT file generated: $dotFileName at active project root.',
  );
  printInfo(
    '👉 To visualize, use: "dot -Tpng $dotFileName -o MONOREPO_ARCHITECTURE.png"',
  );

  final render =
      (ask('Generate PNG automatically? (Requires graphviz) (y/n)') ?? 'n')
          .toLowerCase() ==
      'y';
  if (render) {
    // runCommand uses getActiveProjectPath() internally
    await runCommand('dot', [
      '-Tpng',
      dotFileName,
      '-o',
      'MONOREPO_ARCHITECTURE.png',
    ], loadingMessage: 'Rendering Graph');
  }

  ask('Press Enter to return');
}
