import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> detectCircularDependencies() async {
  printSection('Circular Dependency Detector');
  final featuresDir = Directory('lib/features');
  if (!featuresDir.existsSync()) {
    printWarning('lib/features directory not found. Skipping check.');
    return;
  }

  final Map<String, List<String>> featureDeps = {};
  final features = featuresDir
      .listSync()
      .whereType<Directory>()
      .where((d) => !p.basename(d.path).startsWith('z_'))
      .toList();

  bool hasCycle = false;

  await loadingSpinner(
    'Building feature dependency map and detecting cycles',
    () async {
      // 1. Build Dependency Map
      for (final feature in features) {
        final name = p.basename(feature.path);
        final deps = <String>{};

        final dartFiles = feature
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in dartFiles) {
          final lines = file.readAsLinesSync();
          for (final line in lines) {
            if (line.trim().startsWith('import ')) {
              for (final other in features) {
                final otherName = p.basename(other.path);
                if (otherName == name) continue;
                if (line.contains('/features/$otherName/')) {
                  deps.add(otherName);
                }
              }
            }
          }
        }
        featureDeps[name] = deps.toList();
      }

      // 2. Detect Cycles (DFS)
      final visited = <String>{};
      final stack = <String>{};

      void findCycle(String current, List<String> path) {
        visited.add(current);
        stack.add(current);

        for (final neighbor in featureDeps[current] ?? []) {
          if (!visited.contains(neighbor)) {
            findCycle(neighbor, [...path, current]);
          } else if (stack.contains(neighbor)) {
            hasCycle = true;
            print(
              '\n   $red$bold🚨 CYCLE DETECTED:$reset ${[...path, current, neighbor].join(' -> ')}',
            );
          }
        }
        stack.remove(current);
      }

      for (final feature in featureDeps.keys) {
        if (!visited.contains(feature)) {
          findCycle(feature, []);
        }
      }
    },
  );

  if (!hasCycle) {
    printSuccess('No circular dependencies found between features.');
  } else {
    print(
      '\n   $yellow$bold💡 Tip:$reset Avoid tight coupling between features. Move shared logic to "core" or "shared".',
    );
  }
}
