import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> findUnusedDependencies() async {
  printSection('Unused Dependency Detector');

  final activePath = getActiveProjectPath();
  final pubspecFile = File(p.join(activePath, 'pubspec.yaml'));

  if (!pubspecFile.existsSync()) {
    printError('pubspec.yaml not found at ${pubspecFile.path}.');
    return;
  }

  final libDir = Directory(p.join(activePath, 'lib'));
  if (!libDir.existsSync()) {
    printError('lib directory not found at ${libDir.path}.');
    return;
  }

  await loadingSpinner(
    'Scanning codebase for unused dependencies in $activePath',
    () async {
      final pubspecContent = pubspecFile.readAsStringSync();
      final depsMatch = RegExp(
        r'^dependencies:\s*\n([\s\S]*?)(?=\n\S|$)',
        multiLine: true,
      ).firstMatch(pubspecContent);

      if (depsMatch == null) {
        printInfo('No dependencies found in pubspec.yaml.');
        return;
      }

      final depsBlock = depsMatch.group(1)!;
      final depLines = depsBlock.split('\n');
      final List<String> installedDeps = [];

      for (var line in depLines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty ||
            trimmed.startsWith('#') ||
            trimmed.startsWith('flutter:') ||
            trimmed == 'flutter') {
          continue;
        }
        final parts = trimmed.split(':');
        final name = parts.first.trim();
        if (name.isNotEmpty && name != 'sdk') {
          installedDeps.add(name);
        }
      }

      final libFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();
      final List<String> unused = [];

      for (final dep in installedDeps) {
        bool isUsed = false;
        final importPattern = "package:$dep/";

        for (final file in libFiles) {
          if (file.readAsStringSync().contains(importPattern)) {
            isUsed = true;
            break;
          }
        }

        if (!isUsed) {
          unused.add(dep);
        }
      }

      if (unused.isEmpty) {
        printSuccess('All installed dependencies are in use.');
      } else {
        printWarning('Found ${unused.length} potentially unused dependencies:');
        for (final dep in unused) {
          print('      - $dep');
        }

        final remove =
            (ask('Would you like to remove all unused dependencies? (y/n)') ??
                    'n')
                .toLowerCase() ==
            'y';
        if (remove) {
          for (final dep in unused) {
            // runCommand uses getActiveProjectPath() internally
            await runCommand('flutter', [
              'pub',
              'remove',
              dep,
            ], loadingMessage: 'Removing $dep');
          }
          printSuccess('Cleanup complete.');
        }
      }
    },
  );
}
