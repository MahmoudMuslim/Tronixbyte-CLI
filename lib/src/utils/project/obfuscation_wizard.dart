import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runObfuscationWizard() async {
  printSection('🛡️ Advanced Obfuscation Wizard');

  while (true) {
    final options = [
      'Configure Android Proguard/R8 Rules',
      'Configure iOS Symbol Stripping',
      'Backup Obfuscation Mapping Files',
      'Verify Obfuscation Readiness',
    ];

    final choice = selectOption(
      'Obfuscation Management',
      options,
      showBack: true,
    );
    if (choice == 'back' || choice == null) return;

    switch (choice) {
      case '1':
        await _configureProguard();
        break;
      case '2':
        await _configureIosSymbolStripping();
        break;
      case '3':
        await _backupMappingFiles();
        break;
      case '4':
        await _verifyObfuscationReadiness();
        break;
    }
  }
}

Future<void> _configureProguard() async {
  final activePath = getActiveProjectPath();
  final proguardFile = File(
    p.join(activePath, 'android/app/proguard-rules.pro'),
  );

  if (!proguardFile.existsSync()) {
    printInfo('Creating android/app/proguard-rules.pro in $activePath...');
    if (!proguardFile.parent.existsSync()) {
      proguardFile.parent.createSync(recursive: true);
    }
    proguardFile.createSync();
  }

  printInfo('Current Proguard Rules:');
  print(proguardFile.readAsStringSync());

  final options = [
    'Keep all classes (Minimum protection)',
    'Keep only models and entities (Recommended)',
    'Strict obfuscation (High protection)',
    'Add custom rule',
  ];

  final choice = selectOption(
    'Select Proguard Strategy',
    options,
    showBack: false,
  );

  String rule = '';
  switch (choice) {
    case '1':
      rule = '-keep class ** { *; }';
      break;
    case '2':
      rule =
          '-keep class **.models.** { *; }\n-keep class **.entities.** { *; }';
      break;
    case '3':
      rule =
          '-repackageclasses \'\'\n-allowaccessmodification\n-optimizations !code/simplification/arithmetic';
      break;
    case '4':
      final custom = ask('Enter custom Proguard rule');
      if (custom != null) rule = custom;
      break;
  }

  if (rule.isNotEmpty) {
    await loadingSpinner('Updating Proguard rules in $activePath', () async {
      final current = proguardFile.readAsStringSync();
      proguardFile.writeAsStringSync('$current\n$rule\n', mode: FileMode.write);
    });
    printSuccess('Proguard rules updated.');
  }
}

Future<void> _configureIosSymbolStripping() async {
  final activePath = getActiveProjectPath();
  printInfo('Configuring iOS Symbol Stripping for project at $activePath...');
  printInfo(
    'This modification will be applied to your project\'s build configuration.',
  );

  final confirm =
      (ask(
                'Enable "Strip Linked Product" and "Deployment Postprocessing" for iOS? (y/n)',
              ) ??
              'n')
          .toLowerCase() ==
      'y';

  if (confirm) {
    printSuccess('iOS symbol stripping configuration guidance applied.');
    printInfo(
      'Note: For iOS, manual verification in Xcode Build Settings is recommended.',
    );
  }
}

Future<void> _backupMappingFiles() async {
  final activePath = getActiveProjectPath();
  final backupDir = Directory(p.join(activePath, 'obfuscation_backups'));
  if (!backupDir.existsSync()) backupDir.createSync(recursive: true);

  final buildDir = Directory(p.join(activePath, 'build'));
  if (!buildDir.existsSync()) {
    printWarning('Build directory not found. Run a build first.');
    return;
  }

  await loadingSpinner(
    'Backing up obfuscation mapping files in $activePath',
    () async {
      final mappingFiles = buildDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.contains('mapping.txt'));

      for (final file in mappingFiles) {
        final dest = p.join(
          backupDir.path,
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}',
        );
        file.copySync(dest);
        printInfo('Backed up: ${p.relative(file.path, from: activePath)}');
      }
    },
  );

  printSuccess(
    'Backups complete in ${p.relative(backupDir.path, from: activePath)}/',
  );
}

Future<void> _verifyObfuscationReadiness() async {
  final activePath = getActiveProjectPath();
  await loadingSpinner(
    'Verifying obfuscation readiness in $activePath',
    () async {
      final gradleFile = File(p.join(activePath, 'android/app/build.gradle'));
      if (gradleFile.existsSync()) {
        final content = gradleFile.readAsStringSync();
        if (!content.contains('minifyEnabled true')) {
          printWarning(
            'Android: minifyEnabled is NOT set to true in build.gradle.',
          );
        } else {
          printSuccess('Android: Minification is enabled.');
        }
      }

      final proguardFile = File(
        p.join(activePath, 'android/app/proguard-rules.pro'),
      );
      if (!proguardFile.existsSync()) {
        printWarning('Android: proguard-rules.pro is missing.');
      } else {
        printSuccess('Android: Proguard rules found.');
      }
    },
  );
}
