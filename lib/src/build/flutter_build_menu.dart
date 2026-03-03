import 'package:tools/tools.dart';

Future<void> flutterBuildMenu() async {
  while (true) {
    final options = [
      'Android Hub (APK, AAB, AAR)',
      'iOS Wizard',
      'Web Hub (Advanced Web Builds)',
      'Windows Wizard',
      'MacOS Wizard',
      'Linux Wizard',
      'Bundle (Assets only)',
    ];

    final choice = selectOption('Flutter Build Menu', options, showBack: true);

    if (choice == 'back' || choice == null) return;

    final commonArgs = getCommonBuildArgs();

    switch (choice) {
      case '1':
        await androidBuildMenu();
        break;
      case '2':
        await iosBuildWizard(commonArgs);
        break;
      case '3':
        await webBuildWizard(commonArgs);
        break;
      case '4':
        await windowsBuildWizard(commonArgs);
        break;
      case '5':
        await macosBuildWizard(commonArgs);
        break;
      case '6':
        await linuxBuildWizard(commonArgs);
        break;
      case '7':
        await runCommand('flutter', [
          'build',
          'bundle',
          ...commonArgs,
        ], loadingMessage: 'Building Flutter Bundle');
        printSuccess('Bundle built successfully.');
        break;
      default:
        printError('Invalid option.');
    }
  }
}
