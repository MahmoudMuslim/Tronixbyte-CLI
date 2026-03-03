import 'package:tools/tools.dart';

Future<void> configureFirebase() async {
  printSection('Firebase Configuration');

  // Check if Firebase CLI is installed
  if (!await isFirebaseCliInstalled()) {
    printWarning('Firebase CLI is not detected on your system.');

    // Check if npm is installed
    if (!await isNpmInstalled()) {
      printWarning('npm (Node.js) is also not detected.');
      printInfo(
        'Firebase CLI requires npm to be installed: https://nodejs.org/',
      );

      final installNpmAsk =
          (ask('Attempt to install Node.js (npm) now? (y/n)') ?? 'n')
              .toLowerCase() ==
          'y';
      if (installNpmAsk) {
        await installNpm();
      }
    }

    // Re-check npm before suggesting firebase-tools install
    if (await isNpmInstalled()) {
      printInfo('npm is available. Ready to install firebase-tools.');
      final installFirebase =
          (ask('Try to install firebase-tools via npm? (y/n)') ?? 'n')
              .toLowerCase() ==
          'y';
      if (installFirebase) {
        await installFirebaseTools();
      }
    } else {
      printError('Firebase CLI cannot be installed automatically without npm.');
      printInfo('Please install Node.js manually: https://nodejs.org/');
      return;
    }

    // Final check for firebase CLI
    if (!await isFirebaseCliInstalled()) {
      printError(
        'Firebase CLI installation failed or needs a terminal restart.',
      );
      return;
    }
  }

  while (true) {
    final options = [
      'Firebase Login',
      'Initialize Firebase Project (firebase init)',
      'Configure FlutterFire CLI (Setup Platforms)',
      'Add Firebase Services (Auth, DB, etc.)',
      'Scaffold & Integrate Firebase into App',
    ];

    final choice = selectOption(
      'Firebase Configuration Hub',
      options,
      showBack: true,
    );

    if (choice == 'back' || choice == null) return;

    switch (choice) {
      case '1':
        await runCommand('firebase', ['login']);
        break;
      case '2':
        await runCommand('firebase', ['init']);
        break;
      case '3':
        await setupFlutterFire();
        break;
      case '4':
        await manageFirebaseServices();
        break;
      case '5':
        await scaffoldFirebaseIntegration();
        break;
      default:
        printError('Invalid option.');
    }
  }
}
