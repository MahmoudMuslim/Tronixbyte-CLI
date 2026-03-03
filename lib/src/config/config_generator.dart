import 'package:tools/tools.dart';

Future<void> runConfigGeneratorMenu() async {
  // Ensure we are in a valid project before starting
  await ensureProjectRoot();

  while (true) {
    final projectName = await getProjectName();

    final options = [
      'UI & Extensions (Context, Responsive)',
      'API (Legacy)',
      'Network & API (Dio, Retrofit)',
      'Database (Drift)',
      'Firebase (Auth, DB, Storage)',
      'Shorebird (Code Push)',
      'Theme & Locale (State Management)',
      'Dependency Injection (Service Locator)',
      'Splash Screen (Native Splash)',
      'Ad Services (AdMob)',
      'App Icon Configuration',
      'Package Name & App Name Renaming',
      'Multi-Flavor Configuration (Dev, Stg, Prod)',
    ];

    final choice = selectOption(
      'Project Configuration Hub',
      options,
      showBack: true,
    );

    if (choice == 'back' || choice == null) break;

    switch (choice) {
      case '1':
        await configureUi(projectName);
        break;
      case '2':
        await configureApi(projectName);
        break;
      case '3':
        await configureNetwork(projectName);
        break;
      case '4':
        await configureDatabase();
        break;
      case '5':
        await configureFirebase();
        break;
      case '6':
        await configureShorebird();
        break;
      case '7':
        final stateChoice = selectOption(
          'Select State Management for Theme/Locale',
          ['BLoC', 'Cubit', 'Riverpod', 'GetX', 'Provider'],
          showBack: false,
        );
        String stateType = 'cubit';
        if (stateChoice == '1') stateType = 'bloc';
        if (stateChoice == '3') stateType = 'riverpod';
        if (stateChoice == '4') stateType = 'getx';
        if (stateChoice == '5') stateType = 'provider';
        await configureThemeAndLocale(projectName, stateType);
        break;
      case '8':
        final stateChoiceInj = selectOption(
          'Select State Management for Injection Context',
          ['BLoC', 'Cubit', 'Riverpod', 'GetX', 'Provider'],
          showBack: false,
        );
        String stateTypeInj = 'cubit';
        if (stateChoiceInj == '1') stateTypeInj = 'bloc';
        if (stateChoiceInj == '3') stateTypeInj = 'riverpod';
        if (stateChoiceInj == '4') stateTypeInj = 'getx';
        if (stateChoiceInj == '5') stateTypeInj = 'provider';
        await configureInjection(projectName, stateTypeInj);
        break;
      case '9':
        await configureNativeSplash();
        break;
      case '10':
        await scaffoldAdIntegration();
        break;
      case '11':
        await configureIconsLauncher();
        break;
      case '12':
        await configurePackageRename();
        break;
      case '13':
        await configureProjectFlavors(projectName);
        break;
      default:
        printError('Invalid option.');
    }
  }
}
