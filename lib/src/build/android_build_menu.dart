import 'package:tools/tools.dart';

Future<void> androidBuildMenu() async {
  while (true) {
    final options = [
      'Android - APK Wizard',
      'Android - App Bundle Wizard (AAB)',
      'Android - AAR Wizard (Module)',
    ];

    final choice = selectOption('Android Build Menu', options, showBack: true);

    if (choice == 'back' || choice == null) return;

    try {
      final commonArgs = getCommonBuildArgs();

      switch (choice) {
        case '1':
          await _androidApkBuildWizard(commonArgs);
          break;
        case '2':
          await _androidAabBuildWizard(commonArgs);
          break;
        case '3':
          await _androidAarBuildWizard(commonArgs);
          break;
        default:
          printError('Invalid option.');
      }
    } on BuildAbortException {
      printInfo('Build process cancelled.');
      continue;
    }
  }
}

Future<void> _androidApkBuildWizard(List<String> commonArgs) async {
  printSection('Android APK Build Wizard');
  final args = [...commonArgs];
  final modeStr =
      ask(
        'Build mode (debug/release/profile, "b" to back)',
        defaultValue: 'release',
      ) ??
      'release';
  if (modeStr.toLowerCase() == 'b') return;
  final mode = modeStr.toLowerCase();
  args.add('--$mode');

  if (mode != 'debug') {
    await addObfuscationArgs(args, 'apk');
    final analyze = (ask('Analyze build size? (y/n)', defaultValue: 'n') ?? 'n')
        .toLowerCase();
    if (analyze == 'y') {
      args.add('--analyze-size');
    }
  }

  if ((ask('Split per ABI? (y/n)', defaultValue: 'n') ?? 'n').toLowerCase() ==
      'y') {
    args.add('--split-per-abi');
  }

  final flavor = ask('Flavor (leave empty for none)');
  if (flavor != null) args.add('--flavor=$flavor');

  final targetPlatform = ask(
    'Target platform (android-arm, android-arm64, android-x64 - comma separated)',
  );
  if (targetPlatform != null) args.add('--target-platform=$targetPlatform');

  if ((ask('Tree shake icons? (y/n)', defaultValue: 'y') ?? 'y')
          .toLowerCase() ==
      'n') {
    args.add('--no-tree-shake-icons');
  }

  await runCommand('flutter', [
    'build',
    'apk',
    ...args,
  ], loadingMessage: 'Building Android APK ($mode)');
  printSuccess('Android APK built successfully.');
  ask('Press Enter to return');
}

Future<void> _androidAabBuildWizard(List<String> commonArgs) async {
  printSection('Android App Bundle Build Wizard');
  final args = [...commonArgs];
  final modeStr =
      ask(
        'Build mode (release/profile, "b" to back)',
        defaultValue: 'release',
      ) ??
      'release';
  if (modeStr.toLowerCase() == 'b') return;
  final mode = modeStr.toLowerCase();
  args.add('--$mode');

  if (mode != 'debug') {
    await addObfuscationArgs(args, 'appbundle');
    if ((ask('Analyze build size? (y/n)', defaultValue: 'n') ?? 'n')
            .toLowerCase() ==
        'y') {
      args.add('--analyze-size');
    }
  }

  final flavor = ask('Flavor (leave empty for none)');
  if (flavor != null) args.add('--flavor=$flavor');

  final targetPlatform = ask(
    'Target platform (android-arm, android-arm64, android-x64)',
  );
  if (targetPlatform != null) args.add('--target-platform=$targetPlatform');

  if ((ask('Enable deferred components? (y/n)', defaultValue: 'y') ?? 'y')
          .toLowerCase() !=
      'y') {
    args.add('--no-deferred-components');
  }

  if ((ask('Tree shake icons? (y/n)', defaultValue: 'y') ?? 'y')
          .toLowerCase() ==
      'n') {
    args.add('--no-tree-shake-icons');
  }

  await runCommand('flutter', [
    'build',
    'appbundle',
    ...args,
  ], loadingMessage: 'Building Android App Bundle ($mode)');
  printSuccess('Android App Bundle built successfully.');
  ask('Press Enter to return');
}

Future<void> _androidAarBuildWizard(List<String> commonArgs) async {
  printSection('Android AAR Build Wizard');
  final args = [...commonArgs];
  if ((ask('Build debug? (y/n)', defaultValue: 'y') ?? 'y').toLowerCase() ==
      'n') {
    args.add('--no-debug');
  }
  if ((ask('Build profile? (y/n)', defaultValue: 'y') ?? 'y').toLowerCase() ==
      'n') {
    args.add('--no-profile');
  }
  if ((ask('Build release? (y/n)', defaultValue: 'y') ?? 'y').toLowerCase() ==
      'n') {
    args.add('--no-release');
  }

  final flavor = ask('Flavor (leave empty for none)');
  if (flavor != null) args.add('--flavor=$flavor');

  final targetPlatform = ask(
    'Target platform (android-arm, android-arm64, android-x64)',
  );
  if (targetPlatform != null) args.add('--target-platform=$targetPlatform');

  final output = ask('Output directory path');
  if (output != null) args.addAll(['--output', output]);

  if ((ask('Tree shake icons? (y/n)', defaultValue: 'y') ?? 'y')
          .toLowerCase() ==
      'n') {
    args.add('--no-tree-shake-icons');
  }

  await runCommand('flutter', [
    'build',
    'aar',
    ...args,
  ], loadingMessage: 'Building Android AAR');
  printSuccess('Android AAR built successfully.');
  ask('Press Enter to return');
}
