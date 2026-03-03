import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runDeadCodePurge() async {
  printSection('🧹 Dead Code & Asset Purger');

  final activePath = getActiveProjectPath();
  final libDir = Directory(p.join(activePath, 'lib'));
  if (!libDir.existsSync()) {
    printError('lib directory not found.');
    return;
  }

  final List<String> orphanedFiles = [];

  await loadingSpinner('Analyzing project reachability graph in $activePath', () async {
    final allDartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !p.basename(f.path).startsWith('z_'))
        .toList();

    final mainFile = p.join(activePath, 'lib', 'main.dart');
    final Set<String> reachable = {p.normalize(mainFile)};
    final List<String> queue = [p.normalize(mainFile)];

    final projectName = await getProjectName();

    // 1. Trace Reachability
    while (queue.isNotEmpty) {
      final currentPath = queue.removeAt(0);
      final file = File(currentPath);
      if (!file.existsSync()) continue;

      final content = file.readAsStringSync();
      // Fixed regex to correctly handle both single and double quotes in imports
      final importRegex = RegExp(r'''import\s+['"](.+?)['"]''');
      final matches = importRegex.allMatches(content);

      for (final match in matches) {
        final importUri = match.group(1)!;
        String? resolvedPath;

        if (importUri.startsWith('package:')) {
          // Resolve package import
          if (importUri.startsWith('package:$projectName/')) {
            resolvedPath = p.normalize(p.join(
              activePath,
              'lib',
              importUri.replaceFirst('package:$projectName/', ''),
            ));
          }
        } else if (!importUri.startsWith('dart:')) {
          // Resolve relative import
          resolvedPath = p.normalize(p.join(p.dirname(currentPath), importUri));
        }

        if (resolvedPath != null && resolvedPath.endsWith('.dart')) {
          if (!reachable.contains(resolvedPath)) {
            reachable.add(resolvedPath);
            queue.add(resolvedPath);
          }
        }
      }
    }

    for (final file in allDartFiles) {
      final normalized = p.normalize(file.path);
      if (!reachable.contains(normalized)) {
        orphanedFiles.add(p.relative(normalized, from: activePath));
      }
    }
  });

  if (orphanedFiles.isEmpty) {
    printSuccess('Clean Sweep! All Dart files are reachable from main.dart.');
  } else {
    print('\n$yellow$bold⚠️  ORPHANED DART FILES DETECTED:$reset');
    printInfo('These files are not imported by any other file in the reachability graph.');
    for (var f in orphanedFiles) {
      print('   - $f');
    }

    final delete = (ask('\nDelete these orphaned files? (y/n)') ?? 'n').toLowerCase() == 'y';
    if (delete) {
      for (var f in orphanedFiles) {
        File(p.join(activePath, f)).deleteSync();
      }
      printSuccess('Deleted ${orphanedFiles.length} orphaned files.');
    }
  }

  ask('Press Enter to return');
}
