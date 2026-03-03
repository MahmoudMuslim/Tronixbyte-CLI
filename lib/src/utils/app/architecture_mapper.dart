import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runArchitectureMapping() async {
  printSection('📊 Project Architectural Map (Graphviz)');

  final featuresDir = Directory('lib/features');
  if (!featuresDir.existsSync()) {
    printError('lib/features directory not found.');
    return;
  }

  final StringBuffer dotBuffer = StringBuffer();
  dotBuffer.writeln('digraph G {');
  dotBuffer.writeln('  rankdir=LR;');
  dotBuffer.writeln('  node [shape=box, style=filled, color=lightblue];');

  final List<String> connections = [];

  await loadingSpinner('Crawling feature dependencies', () async {
    final features = featuresDir.listSync().whereType<Directory>();

    for (final feature in features) {
      final name = p.basename(feature.path);
      if (name.startsWith('z_')) continue;

      // Identify dependencies by looking at imports
      final files = feature
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      final Set<String> deps = {};

      for (final file in files) {
        final content = file.readAsStringSync();
        final matches = RegExp(
          r"import 'package:.*?/features/(\w+)/",
        ).allMatches(content);
        for (final match in matches) {
          final depName = match.group(1);
          if (depName != null && depName != name) {
            deps.add(depName);
          }
        }
      }

      for (final dep in deps) {
        connections.add('  "$name" -> "$dep";');
      }
    }
  });

  if (connections.isEmpty) {
    printInfo(
      'No inter-feature dependencies found. Your modules are perfectly isolated!',
    );
  } else {
    for (final conn in connections) {
      dotBuffer.writeln(conn);
    }
  }

  dotBuffer.writeln('}');

  final dotFile = File('ARCHITECTURE.dot');
  dotFile.writeAsStringSync(dotBuffer.toString(), mode: FileMode.write);

  printSuccess('Graphviz DOT file generated: ARCHITECTURE.dot');
  printInfo(
    '👉 To visualize, use: "dot -Tpng ARCHITECTURE.dot -o ARCHITECTURE.png"',
  );

  final open =
      (ask('Generate PNG automatically? (Requires graphviz installed) (y/n)') ??
              'n')
          .toLowerCase() ==
      'y';
  if (open) {
    await runCommand('dot', [
      '-Tpng',
      'ARCHITECTURE.dot',
      '-o',
      'ARCHITECTURE.png',
    ], loadingMessage: 'Rendering PNG');
  }

  ask('Press Enter to return');
}
