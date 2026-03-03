import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> generateBarrelFiles() async {
  printSection('Barrel Chain Synchronizer');

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    printError('lib directory not found.');
    return;
  }

  int createdCount = 0;

  await loadingSpinner('Crawling directories and linking exports', () async {
    void processDirectory(Directory dir) {
      final List<FileSystemEntity> entities = dir.listSync();
      final folderName = p.basename(dir.path);

      // We avoid barrel for 'lib' root, but use it for 'src', 'core', 'features', etc.
      final barrelFile = File(p.join(dir.path, 'z_$folderName.dart'));
      final exports = <String>[];

      // 1. Process Files in current folder (exclude self, generated, and freezed)
      final dartFiles = entities
          .whereType<File>()
          .where(
            (f) =>
                f.path.endsWith('.dart') &&
                p.basename(f.path) != p.basename(barrelFile.path) &&
                !p.basename(f.path).endsWith('.g.dart') &&
                !p.basename(f.path).endsWith('.freezed.dart'),
          )
          .toList();

      for (final file in dartFiles) {
        exports.add("export '${p.basename(file.path)}';");
      }

      // 2. Recurse into Sub-directories and link their barrels
      final subDirs = entities.whereType<Directory>();
      for (final subDir in subDirs) {
        processDirectory(subDir);

        final subFolderName = p.basename(subDir.path);
        // Look for any barrel file in the sub-directory
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
          exports.add("export '$subFolderName/${p.basename(subBarrel.path)}';");
        }
      }

      if (exports.isNotEmpty) {
        exports.sort();
        // Use write mode to avoid appending indefinitely on re-run
        barrelFile.writeAsStringSync('${exports.join('\n')}\n');
        createdCount++;
      }
    }

    processDirectory(libDir);
  });

  printSuccess(
    'Barrel Chain synchronized! $createdCount barrels updated/created.',
  );
}
