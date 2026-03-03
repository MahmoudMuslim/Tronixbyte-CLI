import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> refreshBarrels() async {
  printSection('Barrel Chain Refresher');

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    printError('lib directory not found.');
    return;
  }

  int updatedCount = 0;

  await loadingSpinner('Refreshing existing barrel exports', () async {
    final List<FileSystemEntity> entities = libDir.listSync(recursive: true);
    for (final entity in entities) {
      if (entity is File &&
          p.basename(entity.path).startsWith('z_') &&
          entity.path.endsWith('.dart')) {
        final folder = entity.parent;
        final folderName = p.basename(folder.path);

        if (p.basename(entity.path) == 'z_$folderName.dart' ||
            p.basename(entity.path).startsWith('z_')) {
          final exports = <String>[];

          // 1. Export regular .dart files (exclude self and generated files)
          final dartFiles =
              folder
                  .listSync()
                  .whereType<File>()
                  .where(
                    (f) =>
                        f.path.endsWith('.dart') &&
                        p.basename(f.path) != p.basename(entity.path) &&
                        !p.basename(f.path).endsWith('.g.dart') &&
                        !p.basename(f.path).endsWith('.freezed.dart'),
                  )
                  .map((f) => p.basename(f.path))
                  .toList()
                ..sort();

          exports.addAll(dartFiles.map((name) => "export '$name';"));

          // 2. Export barrel files from immediate sub-folders (Recursive linking)
          final subDirs = folder.listSync().whereType<Directory>();
          for (final subDir in subDirs) {
            final subFolderName = p.basename(subDir.path);
            final subBarrel = subDir
                .listSync()
                .whereType<File>()
                .where(
                  (f) =>
                      p.basename(f.path).startsWith('z_') &&
                      f.path.endsWith('.dart'),
                )
                .firstOrNull;

            if (subBarrel != null) {
              exports.add(
                "export '$subFolderName/${p.basename(subBarrel.path)}';",
              );
            }
          }

          if (exports.isNotEmpty) {
            final content = '${exports.join('\n')}\n';
            // Use write mode to ensure clean refresh
            entity.writeAsStringSync(content);
            updatedCount++;
          }
        }
      }
    }
  });

  printSuccess('Barrel Chain refreshed! $updatedCount barrels updated.');
}
