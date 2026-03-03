import 'package:tools/tools.dart';

Future<void> configureShorebird() async {
  // Ensure we have project context before shorebird operations
  final activePath = getActiveProjectPath();

  // Check if Shorebird is installed
  if (!await ShorebirdCliManager.isInstalled()) {
    printWarning('Shorebird CLI is not detected on your system.');

    final installChoice = selectOption(
      'Would you like to install Shorebird now?',
      ['Yes, install Shorebird'],
      showBack: true,
    );

    if (installChoice == '1') {
      await ShorebirdCliManager.install();
    }
    return;
  }

  while (true) {
    final options = [
      'Shorebird Login / Account Info',
      'Initialize Shorebird (shorebird init)',
      'Shorebird Doctor (Check setup)',
      'List All Releases',
      'Create New Release (Wizard)',
      'Push New Patch (Wizard)',
      'List Patches for a Release',
      'Preview Latest Patch',
      'Add shorebird_code_push package',
      'Scaffold Shorebird Integration (main.dart)',
      'Upgrade Shorebird CLI',
    ];

    final choice = selectOption(
      'Shorebird (Code Push) Hub',
      options,
      showBack: true,
    );

    if (choice == 'back' || choice == null) return;

    switch (choice) {
      case '1':
        await ShorebirdCliManager.login();
        break;
      case '2':
        // runCommand uses getActiveProjectPath() internally
        await runCommand('shorebird', [
          'init',
        ], loadingMessage: 'Initializing Shorebird in $activePath');
        break;
      case '3':
        await ShorebirdCliManager.runDoctor();
        break;
      case '4':
        await runCommand('shorebird', ['releases', 'list']);
        break;
      case '5':
        await _selectPlatformAndRun('Release');
        break;
      case '6':
        await _selectPlatformAndRun('Patch');
        break;
      case '7':
        final version = ask('Enter release version (e.g. 1.0.0)');
        if (version != null) {
          await runCommand('shorebird', [
            'patch',
            'list',
            '--release-version',
            version,
          ]);
        }
        break;
      case '8':
        await runCommand('shorebird', ['preview']);
        break;
      case '9':
        await runCommand('flutter', [
          'pub',
          'add',
          'shorebird_code_push',
        ], loadingMessage: 'Adding shorebird dependency to project');
        break;
      case '10':
        await scaffoldShorebird();
        break;
      case '11':
        await ShorebirdCliManager.upgrade();
        break;
      default:
        printError('Invalid option.');
    }
  }
}

Future<void> _selectPlatformAndRun(String action) async {
  while (true) {
    final platforms = [
      'Android',
      'iOS',
      'Windows (Beta)',
      'MacOS (Beta)',
      'Linux (Beta)',
      'Web (Beta)',
    ];

    final choice = selectOption(
      'Select Platform for $action',
      platforms,
      showBack: true,
    );

    if (choice == 'back' || choice == null) return;

    String? platform;
    switch (choice) {
      case '1':
        platform = 'android';
        break;
      case '2':
        platform = 'ios';
        break;
      case '3':
        platform = 'windows';
        break;
      case '4':
        platform = 'macos';
        break;
      case '5':
        platform = 'linux';
        break;
      case '6':
        platform = 'web';
        break;
    }

    if (platform != null) {
      if (action == 'Release') {
        await shorebirdReleaseWizard(platform);
      } else {
        await shorebirdPatchWizard(platform);
      }
      break;
    }
  }
}
