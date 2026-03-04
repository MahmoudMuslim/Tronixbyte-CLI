import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runFullSetup() async {
  printSection('Elite Full Project Initialization');

  // Ensure we have project context before starting
  await ensureProjectRoot();
  final activePath = getActiveProjectPath();

  String projectName;
  try {
    projectName = await getProjectName();
  } catch (e) {
    printError('Error: $e');
    return;
  }

  String? stateType = getStateType(true);

  if (stateType == 'back' || stateType == null) return;

  printSection('Individual Module Selection');
  final enableNetwork =
      (ask(
                'Integrate Network & API foundation (Dio/Retrofit)? (y/n)',
                defaultValue: 'n',
              ) ??
              'n')
          .toLowerCase() ==
      'y';
  final enableDatabase =
      (ask('Integrate Local Database (Drift)? (y/n)', defaultValue: 'n') ?? 'n')
          .toLowerCase() ==
      'y';
  final enableFirebase =
      (ask('Integrate Firebase Suite? (y/n)', defaultValue: 'n') ?? 'n')
          .toLowerCase() ==
      'y';
  final enableAds =
      (ask('Integrate Ad Services (AdMob)? (y/n)', defaultValue: 'n') ?? 'n')
          .toLowerCase() ==
      'y';
  final enableShorebird =
      (ask('Integrate Shorebird (Code Push)? (y/n)', defaultValue: 'n') ?? 'n')
          .toLowerCase() ==
      'y';
  final enableBoilerplate =
      (ask(
                'Generate Shared UI Boilerplate Widgets? (y/n)',
                defaultValue: 'y',
              ) ??
              'y')
          .toLowerCase() ==
      'y';

  int totalSteps = 10;
  if (enableNetwork) totalSteps++;
  if (enableDatabase) totalSteps++;
  if (enableFirebase) totalSteps++;
  if (enableAds) totalSteps++;
  if (enableShorebird) totalSteps++;
  if (enableBoilerplate) totalSteps++;

  int currentStep = 1;

  // 1. Dependencies
  printStep(
    currentStep++,
    totalSteps,
    'Adding elite dependencies to pubspec.yaml...',
  );

  final List<String> currentDeps = [
    ...baseDeps,
    ...?stateManagementDeps[stateType],
  ];

  final List<String> currentDevDeps = [
    ...baseDevDeps,
    ...?stateManagementDevDeps[stateType],
  ];

  final List<String> currentOverrideDeps = [...baseOverrideDeps];

  await runCommand('flutter', [
    'pub',
    'add',
    ...currentDeps,
  ], loadingMessage: 'Installing production dependencies');
  await runCommand('flutter', [
    'pub',
    'add',
    '--dev',
    ...currentDevDeps,
  ], loadingMessage: 'Installing dev dependencies');
  await runCommand('flutter', [
    'pub',
    'add',
    ...currentOverrideDeps.map((e) => 'override:$e '),
  ], loadingMessage: 'Installing override dependencies');

  // 2. Directories
  printStep(
    currentStep++,
    totalSteps,
    'Creating professional directory structure...',
  );
  final baseDirs = [
    'assets/translations',
    'assets/images',
    'assets/fonts',
    'assets/svgs',
    '.vscode',
    '.github/workflows',
    'lib/src',
    'lib/core/constants',
    'lib/core/theme/manager',
    'lib/core/locale/manager',
    'lib/core/routes',
    'lib/core/utils',
    'lib/core/theme',
    'lib/l10n',
    'lib/shared/widgets',
    'lib/features',
  ];
  for (final dir in baseDirs) {
    final d = Directory(p.join(activePath, dir));
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
  }

  // 3. Base Files
  printStep(
    currentStep++,
    totalSteps,
    'Generating architectural base files (Self-Healing)...',
  );

  final baseFiles = {
    'assets/translations/en.json':
        '{\n  "app_title": "${projectName[0].toUpperCase()}${projectName.substring(1)}"\n}',
    'assets/translations/ar.json':
        '{\n  "app_title": "${projectName[0].toUpperCase()}${projectName.substring(1)}"\n}',
    'lib/l10n/z_l10n.dart': "export 'locale_keys.g.dart';",
    'lib/icons.dart': getIconsTemplate(),
    'lib/main.dart': getMainTemplate(projectName, enableNetwork, stateType),
    'lib/app.dart': getMainAppTemplate(projectName, stateType),
    'lib/core/constants/z_constants.dart': '',
    'lib/$projectName.dart':
        "export 'injection.dart';\nexport 'main.dart';\nexport 'app.dart';\nexport 'src/z_src.dart';",
    'lib/src/z_src.dart':
        "export 'dart.dart'${stateType == 'riverpod' ? ' hide AsyncError' : ''};\nexport 'flutter.dart' hide basicLocaleListResolution,  Path;\nexport 'base.dart';\nexport 'global.dart' hide TextDirection, Context;",
    'lib/core/z_core.dart':
        "export 'constants/z_constants.dart';\nexport 'theme/z_theme.dart';\nexport 'locale/z_locale.dart';\nexport 'routes/z_routes.dart';\nexport 'utils/z_utils.dart';",
    'lib/src/dart.dart':
        "export 'dart:async';\nexport 'dart:developer' show log;\nexport 'dart:convert';\nexport 'dart:io' hide HttpResponse;\nexport 'dart:math' hide log;\nexport 'dart:core';",
    'lib/src/flutter.dart':
        "export 'package:flutter/material.dart';\nexport 'package:flutter/cupertino.dart'  hide RefreshCallback;\nexport 'package:flutter/foundation.dart';\nexport 'package:flutter/services.dart';\nexport 'package:flutter/gestures.dart';",
    'lib/src/base.dart':
        "export '../core/z_core.dart';\nexport '../features/z_features.dart';\nexport '../l10n/z_l10n.dart';\nexport '../shared/z_shared.dart';",
    'lib/src/global.dart':
        "// Package dependencies\n${currentDeps.map((e) {
          if (e.contains('drift') || e.contains('colorful_iconify_flutter') || e.contains('iconify_flutter_plus')) return '';
          if (e.contains('retrofit')) return "export 'package:$e/$e.dart' hide Headers,Parser;";
          if (e.contains('dartz')) return "export 'package:$e/$e.dart' hide State;";
          if (e.contains('intl')) return "export 'package:$e/$e.dart' hide TextDirection;";
          if (e.contains('easy_localization')) return "export 'package:$e/$e.dart' hide TextDirection;";
          return "export 'package:$e/$e.dart';";
        }).join('\n')}",
    'analysis_options.yaml': getAnalysisOptionsTemplate(),
    '.gitignore': getGitignoreTemplate(),
    '.vscode/settings.json': getVSCodeSettingsTemplate(),
    '.vscode/extensions.json': getVSCodeExtensionsTemplate(),
  };

  baseFiles.forEach((path, content) {
    final file = File(p.join(activePath, path));
    if (!file.parent.existsSync()) file.parent.createSync(recursive: true);
    if (!file.existsSync()) {
      file.writeAsStringSync(content);
      printInfo('Restored/Created critical file: $path');
    }
  });

  // 4. Core Logic configuration
  printStep(
    currentStep++,
    totalSteps,
    'Configuring Core Logic (Theme & Locale)...',
  );
  await configureThemeAndLocale(projectName, stateType);

  // 5. UI foundations
  printStep(
    currentStep++,
    totalSteps,
    'Configuring UI foundations & Extensions...',
  );
  await configureUi(projectName, stateType);

  // 6. Network foundation
  if (enableNetwork) {
    printStep(
      currentStep++,
      totalSteps,
      'Configuring Network & API foundation...',
    );
    await configureNetwork(projectName);
  }

  // 7. Database foundation
  if (enableDatabase) {
    printStep(
      currentStep++,
      totalSteps,
      'Configuring Local Database (Drift)...',
    );
    await configureDatabase();
  }

  // 8. Shared UI Boilerplate
  if (enableBoilerplate) {
    printStep(
      currentStep++,
      totalSteps,
      'Generating Elite Shared UI Boilerplate...',
    );
    await generateSharedUiBoilerplate();
  }

  // 9. Injection configuration
  printStep(currentStep++, totalSteps, 'Configuring Dependency Injection...');
  await configureInjection(projectName, stateType);

  // 10. Firebase & Ads Integration
  if (enableFirebase) {
    printStep(
      currentStep++,
      totalSteps,
      'Scaffolding workable Firebase integration...',
    );
    await scaffoldFirebaseIntegration();
  }
  if (enableAds) {
    printStep(
      currentStep++,
      totalSteps,
      'Scaffolding workable Ad integration...',
    );
    await scaffoldAdIntegration();
  }

  // 11. Shorebird Integration
  if (enableShorebird) {
    printStep(
      currentStep++,
      totalSteps,
      'Scaffolding workable Shorebird integration...',
    );
    await configureShorebird();
  }

  // 12. Initial Feature
  printStep(
    currentStep++,
    totalSteps,
    'Generating initial Splash & Home structure...',
  );
  bool needData =
      (ask('Add Data Layer for Splash? (y/n)', defaultValue: 'n') ?? 'n')
          .toLowerCase() ==
      'y';
  bool needDomain =
      (ask('Add Domain Layer for Splash? (y/n)', defaultValue: 'n') ?? 'n')
          .toLowerCase() ==
      'y';
  await generateFeature(
    'splash',
    stateType,
    needPresentation: true,
    needRoute: true,
    needData: needData,
    needDomain: needDomain,
  );
  await generateFeature(
    'home',
    stateType,
    needPresentation: true,
    needRoute: true,
    needData: true,
    needDomain: true,
  );

  // Final synchronization
  printStep(currentStep++, totalSteps, 'Running project synchronization...');
  await runCommand('dart', [
    'run',
    'easy_localization:generate',
    '-S',
    'assets/translations',
    '-f',
    'keys',
    '-o',
    'locale_keys.g.dart',
    '-O',
    'lib/l10n',
  ], loadingMessage: 'Generating localization keys');
  printSuccess('Keys generated successfully.');
  await runCommand('flutter', [
    'pub',
    'get',
  ], loadingMessage: 'Updating packages');
  await runCommand('flutter', [
    'pub',
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ], loadingMessage: 'Generating code');

  printSuccess('Elite project initialization complete in $activePath!');
}
