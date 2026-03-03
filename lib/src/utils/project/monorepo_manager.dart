import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runMonorepoManager() async {
  printSection('📦 Multi-Repo Package Manager');

  final activePath = getActiveProjectPath();
  final packagesDir = Directory(p.join(activePath, 'packages'));

  if (!packagesDir.existsSync()) {
    printWarning('No "packages/" directory found at active project root.');
    final create =
        (ask('Is this a new monorepo? Create "packages/" folder in $activePath? (y/n)') ??
                'n')
            .toLowerCase() ==
        'y';
    if (create) {
      packagesDir.createSync();
      printSuccess('Created "packages/" directory.');
    } else {
      return;
    }
  }

  while (true) {
    final options = [
      'Initialize Melos (Monorepo Tool)',
      'Run "pub get" in all packages',
      'Run "clean" in all packages',
      'List all local packages',
      'Check version consistency',
      'Sync all packages to a specific version',
      'Multi-Repo Version Pusher (Tag & Push)',
      'Multi-Repo Change Summary (Uncommitted Dash)',
      'Multi-Repo Dependency Graph (Visualizer)',
      'Multi-Repo Workspace Cleaner (Nuclear Clean)',
    ];

    final choice = selectOption('Monorepo Management', options, showBack: true);
    if (choice == 'back' || choice == null) return;

    switch (choice) {
      case '1':
        await _initMelos(activePath);
        break;
      case '2':
        await _runAcrossPackages(packagesDir, [
          'pub',
          'get',
        ], 'Running pub get');
        break;
      case '3':
        await _runAcrossPackages(
          packagesDir,
          ['clean'],
          'Cleaning packages',
          isFlutter: true,
        );
        break;
      case '4':
        await _listPackages(packagesDir, activePath);
        break;
      case '5':
        await _checkVersionConsistency(packagesDir);
        break;
      case '6':
        await _syncPackageVersions(packagesDir);
        break;
      case '7':
        await _runVersionPusher(activePath);
        break;
      case '8':
        await _runChangeSummary(packagesDir);
        break;
      case '9':
        await runMonorepoDependencyGraph();
        break;
      case '10':
        await _runWorkspaceCleaner(packagesDir);
        break;
    }
  }
}

Future<void> _initMelos(String activePath) async {
  await loadingSpinner(
    'Initializing Melos configuration in $activePath',
    () async {
      // runCommand already uses activePath
      await runCommand('dart', ['pub', 'add', 'dev:melos']);
      final melosFile = File(p.join(activePath, 'melos.yaml'));
      if (!melosFile.existsSync()) {
        melosFile.writeAsStringSync(
          getMonoRepoMelosTemplate(),
          mode: FileMode.write,
        );
      }
    },
  );
  printSuccess('Melos initialized. Run "melos bootstrap" to link packages.');
}

Future<void> _runAcrossPackages(
  Directory packagesDir,
  List<String> args,
  String message, {
  bool isFlutter = false,
}) async {
  final entities = packagesDir.listSync().whereType<Directory>();

  await loadingSpinner('$message across all packages', () async {
    for (final dir in entities) {
      final hasPubspec = File(p.join(dir.path, 'pubspec.yaml')).existsSync();
      if (hasPubspec) {
        printInfo('Targeting: ${p.basename(dir.path)}');
        final cmd = isFlutter ? 'flutter' : 'dart';
        await Process.run(
          cmd,
          args,
          workingDirectory: dir.path,
          runInShell: true,
        );
      }
    }
  });
  printSuccess('Operation complete for all packages.');
}

Future<void> _listPackages(Directory packagesDir, String activePath) async {
  final entities = packagesDir.listSync().whereType<Directory>().toList();

  final List<List<String>> rows = [];
  for (final dir in entities) {
    final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
    if (pubspec.existsSync()) {
      final content = pubspec.readAsStringSync();
      final name =
          RegExp(r'name:\s+(.*)').firstMatch(content)?.group(1) ??
          p.basename(dir.path);
      final version =
          RegExp(r'version:\s+(.*)').firstMatch(content)?.group(1) ?? 'N/A';
      rows.add([name, version, p.relative(dir.path, from: activePath)]);
    }
  }

  print('\n$blue$bold📦 REGISTERED PACKAGES in $activePath$reset');
  printTable(['Package Name', 'Version', 'Location'], rows);
  ask('Press Enter to return');
}

Future<void> _checkVersionConsistency(Directory packagesDir) async {
  final entities = packagesDir.listSync().whereType<Directory>();
  final Map<String, String> versions = {};
  bool inconsistent = false;

  await loadingSpinner('Analyzing version strings', () async {
    for (final dir in entities) {
      final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        final content = pubspec.readAsStringSync();
        final version = RegExp(
          r'version:\s+(.*)',
        ).firstMatch(content)?.group(1);
        if (version != null) {
          versions[p.basename(dir.path)] = version;
        }
      }
    }
  });

  if (versions.isEmpty) {
    printInfo('No packages found to check.');
    return;
  }

  final firstVersion = versions.values.first;
  versions.forEach((pkg, v) {
    if (v != firstVersion) inconsistent = true;
  });

  if (inconsistent) {
    printWarning('Version mismatch detected!');
    final List<List<String>> rows = [];
    versions.forEach((pkg, v) => rows.add([pkg, v]));
    printTable(['Package', 'Version'], rows);
  } else {
    printSuccess('All packages are synchronized at version $firstVersion');
  }
  ask('Press Enter to return');
}

Future<void> _syncPackageVersions(Directory packagesDir) async {
  final targetVersion = ask('Enter Target Version (e.g., 1.0.0+1)');
  if (targetVersion == null || targetVersion.isEmpty) return;

  final entities = packagesDir.listSync().whereType<Directory>();

  await loadingSpinner(
    'Synchronizing all packages to $targetVersion',
    () async {
      for (final dir in entities) {
        final pubspecFile = File(p.join(dir.path, 'pubspec.yaml'));
        if (pubspecFile.existsSync()) {
          String content = pubspecFile.readAsStringSync();
          content = content.replaceFirst(
            RegExp(r'version:\s+.*'),
            'version: $targetVersion',
          );
          pubspecFile.writeAsStringSync(content, mode: FileMode.write);
          printInfo('Synced: ${p.basename(dir.path)}');
        }
      }
    },
  );

  printSuccess('All packages successfully synchronized to $targetVersion');
  ask('Press Enter to return');
}

Future<void> _runVersionPusher(String activePath) async {
  printInfo(
    'This tool will tag and push all packages in the monorepo at $activePath.',
  );
  final version = ask('Enter Tag Version (e.g., v1.2.0)');
  if (version == null) return;

  await loadingSpinner('Tagging and Pushing Monorepo', () async {
    // 1. Git Tag
    await Process.run('git', ['tag', version], workingDirectory: activePath);
    // 2. Git Push Tags
    await Process.run('git', [
      'push',
      'origin',
      version,
    ], workingDirectory: activePath);
    // 3. Git Push Code
    await Process.run('git', [
      'push',
      'origin',
      'HEAD',
    ], workingDirectory: activePath);
  });

  printSuccess('Monorepo version $version pushed to origin!');
  ask('Press Enter to return');
}

Future<void> _runChangeSummary(Directory packagesDir) async {
  printSection('Multi-Repo Change Summary');

  final List<List<String>> rows = [];

  await loadingSpinner(
    'Aggregating uncommitted changes across packages',
    () async {
      final entities = packagesDir.listSync().whereType<Directory>();
      for (final dir in entities) {
        final result = await Process.run('git', [
          'status',
          '--short',
        ], workingDirectory: dir.path);
        final changes = result.stdout.toString().trim();
        final count = changes.isEmpty
            ? '0'
            : changes.split('\n').length.toString();
        final status = changes.isEmpty ? '✅ Clean' : '⚠️ $count Pending';
        rows.add([p.basename(dir.path), status]);
      }
    },
  );

  print('\n$blue$bold🚀 RELEASE READINESS DASHBOARD$reset');
  printTable(['Package', 'Status'], rows);

  print('\n$cyan$bold💡 NEXT STEPS$reset');
  print('   - Run "Multi-Repo Version Pusher" if all packages are Clean.');
  print('   - Commit pending changes in highlighted packages before release.');

  ask('Press Enter to return');
}

Future<void> _runWorkspaceCleaner(Directory packagesDir) async {
  printSection('Multi-Repo Workspace Cleaner');
  final confirm =
      (ask(
                'Nuclear Clean? This will run clean, delete .dart_tool and pubspec.lock in all packages. (y/n)',
              ) ??
              'n')
          .toLowerCase() ==
      'y';
  if (!confirm) return;

  await loadingSpinner('Performing Nuclear Workspace Clean', () async {
    final entities = packagesDir.listSync().whereType<Directory>();
    for (final dir in entities) {
      final hasPubspec = File(p.join(dir.path, 'pubspec.yaml')).existsSync();
      if (hasPubspec) {
        printInfo('Cleaning: ${p.basename(dir.path)}');
        // 1. Flutter Clean
        await Process.run(
          'flutter',
          ['clean'],
          workingDirectory: dir.path,
          runInShell: true,
        );
        // 2. Remove .dart_tool
        final dartTool = Directory(p.join(dir.path, '.dart_tool'));
        if (dartTool.existsSync()) dartTool.deleteSync(recursive: true);
        // 3. Remove pubspec.lock
        final lock = File(p.join(dir.path, 'pubspec.lock'));
        if (lock.existsSync()) lock.deleteSync();
      }
    }
  });

  printSuccess('Workspace is now clean and artifacts purged.');
  printInfo('👉 Run "Run pub get in all packages" to restore dependencies.');
  ask('Press Enter to return');
}
