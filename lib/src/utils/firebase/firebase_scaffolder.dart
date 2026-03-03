import 'package:tools/tools.dart';

Future<void> scaffoldFirebaseIntegration({
  List<String>? enabledProviders,
}) async {
  printSection('Firebase Integration Scaffolder');

  final projectName = await getProjectName();
  final pubspec = File('pubspec.yaml').readAsStringSync();

  // Detect State Management
  String stateType = 'bloc';
  if (pubspec.contains('hooks_riverpod')) {
    stateType = 'riverpod';
  } else if (pubspec.contains('get:')) {
    stateType = 'getx';
  } else if (pubspec.contains('provider:')) {
    stateType = 'provider';
  } else if (pubspec.contains('flutter_bloc:')) {
    stateType = 'bloc';
  }

  await loadingSpinner(
    'Integrating Firebase Elite Suite (Multi-platform)',
    () async {
      // 1. Create Core Services Directory
      final serviceDir = Directory('lib/core/services');
      if (!serviceDir.existsSync()) serviceDir.createSync(recursive: true);

      // 2. Create NotificationService (Workable bridge for all platforms)
      await scaffoldNotificationService(projectName);

      // 3. Create FirebaseService (The Main Orchestrator)
      await generateFirebaseService(
        projectName,
        pubspec,
        enabledProviders: enabledProviders,
      );

      // 4. Register in Injection container (lib/injection.dart)
      await wireFirebaseInjection(pubspec);

      // 5. Scaffold Reactive Auth Logic based on selected architecture
      await scaffoldAuthLogic(
        projectName,
        stateType,
        pubspec,
        enabledProviders: enabledProviders,
      );

      // 6. Multi-Platform Specifics (Permissions & XML Configs)
      await configureFirebasePlatforms(pubspec);

      // 7. Update main.dart
      final mainFile = File('lib/main.dart');
      if (mainFile.existsSync()) {
        String content = mainFile.readAsStringSync();
        if (!content.contains('FirebaseService.init()')) {
          content = content.replaceFirst(
            'WidgetsFlutterBinding.ensureInitialized();',
            'WidgetsFlutterBinding.ensureInitialized();\n\n  // Initialize Firebase & Notifications (Multi-platform)\n  await FirebaseService.init();',
          );
          mainFile.writeAsStringSync(content);
          printInfo('Firebase init added to lib/main.dart');
        }
      }
    },
  );

  printSuccess(
    'Firebase Multi-Platform integration complete and synced with $stateType!',
  );
}
