import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> generateFirebaseService(
  String projectName,
  String pubspec, {
  List<String>? enabledProviders,
}) async {
  final activePath = getActiveProjectPath();
  print(
    '   📄 Generating lib/core/services/firebase_service.dart in $activePath...',
  );

  final serviceDir = Directory(p.join(activePath, 'lib', 'core', 'services'));
  if (!serviceDir.existsSync()) serviceDir.createSync(recursive: true);

  final serviceFile = File(p.join(serviceDir.path, 'firebase_service.dart'));
  final buffer = StringBuffer();

  buffer.writeln("import 'package:$projectName/$projectName.dart';");
  buffer.writeln("import 'package:$projectName/firebase_options.dart';");

  if (pubspec.contains('firebase_ui_auth')) {
    buffer.writeln("import 'package:firebase_ui_auth/firebase_ui_auth.dart';");
  }
  if (pubspec.contains('firebase_ui_firestore')) {
    buffer.writeln(
      "import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';",
    );
  }
  if (pubspec.contains('firebase_ui_database')) {
    buffer.writeln(
      "import 'package:firebase_ui_database/firebase_ui_database.dart';",
    );
  }

  buffer.writeln("");
  buffer.writeln("class FirebaseService {");
  buffer.writeln("  static Future<void> init() async {");
  buffer.writeln("    await Firebase.initializeApp(");
  buffer.writeln("      options: DefaultFirebaseOptions.currentPlatform,");
  buffer.writeln("    );");
  buffer.writeln("");

  buffer.writeln("    // Initialize Notifications bridge");
  buffer.writeln("    await NotificationService.init();");
  buffer.writeln("");

  if (pubspec.contains('firebase_app_check')) {
    buffer.writeln("    // Initialize App Check");
    buffer.writeln("    await FirebaseAppCheck.instance.activate(");
    buffer.writeln("      androidProvider: AndroidProvider.playIntegrity,");
    buffer.writeln("      appleProvider: AppleProvider.deviceCheck,");
    buffer.writeln("    );");
  }

  if (pubspec.contains('firebase_crashlytics')) {
    buffer.writeln("    // Initialize Crashlytics");
    buffer.writeln("    if (!kDebugMode) {");
    buffer.writeln(
      "      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);",
    );
    buffer.writeln(
      "      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;",
    );
    buffer.writeln("    }");
  }

  if (pubspec.contains('firebase_messaging')) {
    buffer.writeln("    // Initialize Messaging");
    buffer.writeln("    final messaging = FirebaseMessaging.instance;");
    buffer.writeln(
      "    await messaging.requestPermission(alert: true, badge: true, sound: true);",
    );
    buffer.writeln("");
    buffer.writeln("    // Foreground Messaging Handler");
    buffer.writeln(
      "    FirebaseMessaging.onMessage.listen((RemoteMessage message) {",
    );
    buffer.writeln("      if (message.notification != null) {");
    buffer.writeln(
      "        NotificationService.showLocalNotification(message);",
    );
    buffer.writeln("      }");
    buffer.writeln("    });");
    buffer.writeln("");
    buffer.writeln(
      "    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);",
    );
  }

  if (pubspec.contains('firebase_ui_auth')) {
    buffer.writeln("    // Configure Firebase UI Auth");
    final providerConfigs = <String>[];
    if (enabledProviders != null) {
      if (enabledProviders.contains('email')) {
        providerConfigs.add('EmailAuthProvider()');
      }
      if (enabledProviders.contains('phone')) {
        providerConfigs.add('PhoneAuthProvider()');
      }
      if (enabledProviders.contains('google')) {
        providerConfigs.add('GoogleProvider(clientId: "")');
      }
      if (enabledProviders.contains('facebook')) {
        providerConfigs.add('FacebookProvider(clientId: "")');
      }
      if (enabledProviders.contains('apple')) {
        providerConfigs.add('AppleProvider()');
      }
      if (enabledProviders.contains('twitter')) {
        providerConfigs.add('TwitterProvider(apiKey: "", apiSecretKey: "")');
      }
    } else {
      providerConfigs.add('EmailAuthProvider()');
    }
    buffer.writeln(
      "    FirebaseUIAuth.configureProviders([${providerConfigs.join(', ')}]);",
    );
  }

  if (pubspec.contains('firebase_remote_config')) {
    buffer.writeln("    // Initialize Remote Config");
    buffer.writeln("    final remoteConfig = FirebaseRemoteConfig.instance;");
    buffer.writeln(
      "    await remoteConfig.setConfigSettings(RemoteConfigSettings(",
    );
    buffer.writeln("      fetchTimeout: const Duration(minutes: 1),");
    buffer.writeln("      minimumFetchInterval: const Duration(hours: 1),");
    buffer.writeln("    ));");
    buffer.writeln("    await remoteConfig.fetchAndActivate();");
  }

  buffer.writeln("  }");
  buffer.writeln("}");

  if (pubspec.contains('firebase_messaging')) {
    buffer.writeln("");
    buffer.writeln("@pragma('vm:entry-point')");
    buffer.writeln(
      "Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {",
    );
    buffer.writeln("  await Firebase.initializeApp();");
    buffer.writeln("  // Handle background message");
    buffer.writeln("}");
  }

  serviceFile.writeAsStringSync(buffer.toString());

  // Update Barrel
  final barrelFile = File(
    p.join(activePath, 'lib', 'core', 'services', 'z_services.dart'),
  );
  const exportLine = "export 'firebase_service.dart';\n";
  if (!barrelFile.existsSync()) {
    barrelFile.writeAsStringSync(exportLine);
  } else {
    String content = barrelFile.readAsStringSync();
    if (!content.contains('firebase_service.dart')) {
      barrelFile.writeAsStringSync('$content$exportLine');
    }
  }
}
