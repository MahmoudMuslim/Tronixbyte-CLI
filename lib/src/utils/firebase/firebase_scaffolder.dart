import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> scaffoldFirebaseIntegration({
  List<String>? enabledProviders,
}) async {
  printSection('Firebase Integration Scaffolder');

  final activePath = getActiveProjectPath();
  final projectName = await getProjectName();
  final pubspecFile = File(p.join(activePath, 'pubspec.yaml'));

  if (!pubspecFile.existsSync()) {
    printError('pubspec.yaml not found at ${pubspecFile.path}');
    return;
  }

  final pubspec = pubspecFile.readAsStringSync();

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

  await loadingSpinner('Integrating Firebase Elite Suite (Multi-platform)', () async {
    // 1. Create Core Services Directory
    final serviceDir = Directory(p.join(activePath, 'lib', 'core', 'services'));
    if (!serviceDir.existsSync()) serviceDir.createSync(recursive: true);

    // 2. Create NotificationService (Workable bridge for all platforms)
    // Note: Assuming scaffoldNotificationService is updated to use activePath internally
    // or we pass it if needed. For now, most sub-scaffolders should use getActiveProjectPath()
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
    final mainFile = File(p.join(activePath, 'lib', 'main.dart'));
    if (mainFile.existsSync()) {
      String content = mainFile.readAsStringSync();
      if (!content.contains('FirebaseService.init()')) {
        content = content.replaceFirst(
          'WidgetsFlutterBinding.ensureInitialized();',
          'WidgetsFlutterBinding.ensureInitialized();\n\n  // Initialize Firebase & Notifications (Multi-platform)\n  await FirebaseService.init();',
        );
        mainFile.writeAsStringSync(content);
        printInfo('Firebase init added to ${mainFile.path}');
      }
    }
  });

  printSuccess(
    'Firebase Multi-Platform integration complete and synced with $stateType!',
  );
}
