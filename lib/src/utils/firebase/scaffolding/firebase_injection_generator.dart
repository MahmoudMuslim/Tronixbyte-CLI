import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> wireFirebaseInjection(String pubspec) async {
  final activePath = getActiveProjectPath();
  final injectionFile = File(p.join(activePath, 'lib', 'injection.dart'));

  if (!injectionFile.existsSync()) {
    printWarning(
      'lib/injection.dart not found in $activePath. Skipping Firebase wiring.',
    );
    return;
  }

  printInfo('Wiring Firebase Elite Suite into lib/injection.dart...');
  String content = injectionFile.readAsStringSync();

  final List<String> injections = [];

  if (pubspec.contains('firebase_auth')) {
    injections.add("  sl.registerLazySingleton(() => FirebaseAuth.instance);");
  }
  if (pubspec.contains('cloud_firestore')) {
    injections.add(
      "  sl.registerLazySingleton(() => FirebaseFirestore.instance);",
    );
  }
  if (pubspec.contains('firebase_database')) {
    injections.add(
      "  sl.registerLazySingleton(() => FirebaseDatabase.instance);",
    );
  }
  if (pubspec.contains('firebase_storage')) {
    injections.add(
      "  sl.registerLazySingleton(() => FirebaseStorage.instance);",
    );
  }
  if (pubspec.contains('firebase_messaging')) {
    injections.add(
      "  sl.registerLazySingleton(() => FirebaseMessaging.instance);",
    );
  }
  if (pubspec.contains('firebase_analytics')) {
    injections.add(
      "  sl.registerLazySingleton(() => FirebaseAnalytics.instance);",
    );
  }
  if (pubspec.contains('firebase_remote_config')) {
    injections.add(
      "  sl.registerLazySingleton(() => FirebaseRemoteConfig.instance);",
    );
  }
  if (pubspec.contains('firebase_app_check')) {
    injections.add(
      "  sl.registerLazySingleton(() => FirebaseAppCheck.instance);",
    );
  }
  if (pubspec.contains('firebase_in_app_messaging')) {
    injections.add(
      "  sl.registerLazySingleton(() => FirebaseInAppMessaging.instance);",
    );
  }

  // Notifications always added if Firebase integration is triggered
  injections.add(
    "  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());",
  );

  if (injections.isNotEmpty && !content.contains('FirebaseAuth.instance')) {
    await loadingSpinner(
      'Injecting Firebase services into $activePath',
      () async {
        final injectionBlock =
            "\n  // --- Firebase & Cloud Services ---\n${injections.join('\n')}";
        content = content.replaceFirst(
          '// --- Core ---',
          '// --- Core ---$injectionBlock',
        );
        injectionFile.writeAsStringSync(content);
      },
    );
    printSuccess('Firebase injection wiring complete.');
  }
}
