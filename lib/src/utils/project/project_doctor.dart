import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runProjectDoctor() async {
  printSection('Project Doctor (Health Diagnosis)');
  final projectName = await getProjectName();
  int issuesFound = 0;
  int warningsFound = 0;

  void reportIssue(String message) {
    printError('ISSUE: $message');
    issuesFound++;
  }

  void reportWarning(String message) {
    printWarning('WARNING: $message');
    warningsFound++;
  }

  void reportSuccessStatus(String message) {
    printSuccess(message);
  }

  await loadingSpinner('Diagnosing project health', () async {
    print('\n$blue$bold📁 Structural Integrity$reset');
    final requiredDirs = [
      'lib/core',
      'lib/features',
      'lib/shared',
      'lib/src',
      'assets/translations',
      'assets/images',
    ];

    for (final dir in requiredDirs) {
      if (Directory(dir).existsSync()) {
        reportSuccessStatus('Directory $dir found.');
      } else {
        reportIssue('Missing critical directory: $dir');
      }
    }

    print('\n$blue$bold📄 Core Files Presence$reset');
    final requiredFiles = [
      'pubspec.yaml',
      'lib/main.dart',
      'lib/app.dart',
      'lib/injection.dart',
      'lib/$projectName.dart',
      'lib/src/z_src.dart',
      '.env.dev',
      '.env.stg',
      '.env.prod',
      'analysis_options.yaml',
    ];

    for (final file in requiredFiles) {
      if (File(file).existsSync()) {
        reportSuccessStatus('File $file found.');
      } else {
        if (file.startsWith('.env.')) {
          reportWarning('Missing environment file: $file');
        } else {
          reportIssue('Missing critical file: $file');
        }
      }
    }

    print('\n$blue$bold🔐 Environment Synchronization$reset');
    await validateEnvSync();

    print('\n$blue$bold🔗 Barrel File Consistency$reset');
    final libDir = Directory('lib');
    if (libDir.existsSync()) {
      final List<FileSystemEntity> entities = libDir.listSync(recursive: true);
      for (final entity in entities) {
        if (entity is Directory) {
          final folderName = p.basename(entity.path);
          if ([
            'features',
            'src',
            'core',
            'shared',
            'widgets',
            'screens',
            'datasources',
            'models',
            'repositories',
            'entities',
            'usecases',
          ].contains(folderName)) {
            final barrelFile = File(p.join(entity.path, 'z_$folderName.dart'));
            if (!barrelFile.existsSync()) {
              final hasDartFiles = entity.listSync().any(
                (e) =>
                    e is File &&
                    e.path.endsWith('.dart') &&
                    !p.basename(e.path).startsWith('z_'),
              );
              if (hasDartFiles) {
                reportWarning(
                  'Missing barrel file in $folderName: ${barrelFile.path}',
                );
              }
            }
          }
        }
      }
    }

    print('\n$blue$bold🛡️  Feature Isolation$reset');
    final violations = await checkFeatureDependencies();
    if (violations > 0) {
      reportWarning('$violations feature isolation violations found.');
    }

    print('\n$blue$bold🌐 Localization Status$reset');
    await validateLocalization();

    print('\n$blue$bold🔥 Cloud & Delivery$reset');
    if (File('lib/core/services/firebase_service.dart').existsSync()) {
      reportSuccessStatus('Firebase Integration detected.');
    } else {
      reportWarning('Firebase Integration not found.');
    }

    if (File('shorebird.yaml').existsSync()) {
      reportSuccessStatus('Shorebird Code Push detected.');
    } else {
      reportWarning('Shorebird Code Push not initialized.');
    }

    print('\n$blue$bold🏗️ Dependency Analysis$reset');
    final pubspecContent = File('pubspec.yaml').readAsStringSync();
    final criticalDeps = [
      'get_it',
      'go_router',
      'easy_localization',
      'dio',
      'drift',
    ];
    for (final dep in criticalDeps) {
      if (!pubspecContent.contains(dep)) {
        reportWarning(
          '$dep not found in pubspec.yaml. This is unusual for a Tronixbyte project.',
        );
      }
    }
  });

  print('\n$blue$bold${'=' * 60}$reset');
  if (issuesFound == 0 && warningsFound == 0) {
    printSuccess(
      'STATUS: Project is PERFECT and follows all Tronixbyte standards.',
    );
  } else {
    printWarning(
      'STATUS: Project has $issuesFound Critical Issues and $warningsFound Warnings.',
    );
    if (issuesFound > 0) {
      printInfo(
        '👉 RECOMMENDATION: Run "Project Repair" to fix critical issues.',
      );
    }
  }
}
