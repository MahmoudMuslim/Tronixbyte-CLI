import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> configureFirebasePlatforms(String pubspec) async {
  final activePath = getActiveProjectPath();

  await loadingSpinner(
    'Configuring platform-specific Firebase settings in $activePath',
    () async {
      await _updateAndroidManifest(pubspec, activePath);
      await _updateIosPlist(pubspec, activePath);
      await _updateMacosEntitlements(activePath);
      await _updateWindowsManifest(activePath);
      await _updateLinuxConfig(activePath);
    },
  );

  printSuccess('Firebase platform configurations synchronized.');
}

Future<void> _updateAndroidManifest(String pubspec, String activePath) async {
  final file = File(
    p.join(activePath, 'android/app/src/main/AndroidManifest.xml'),
  );
  if (!file.existsSync()) return;

  printInfo('Updating AndroidManifest.xml for Firebase & Notifications...');
  String content = file.readAsStringSync();

  final permissions = [
    '<uses-permission android:name="android.permission.INTERNET" />',
    '<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />',
    '<uses-permission android:name="android.permission.WAKE_LOCK" />',
    '<uses-permission android:name="android.permission.VIBRATE" />',
    if (pubspec.contains('firebase_messaging')) ...[
      '<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />',
      '<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />',
    ],
    if (pubspec.contains('firebase_analytics'))
      '<uses-permission android:name="com.google.android.gms.permission.AD_ID" />',
  ];

  for (final prm in permissions) {
    if (!content.contains(prm)) {
      content = content.replaceFirst('<manifest', '<manifest\n    $prm');
    }
  }

  // Add notification metadata and high importance channel if messaging enabled
  if (pubspec.contains('firebase_messaging')) {
    if (!content.contains(
      'com.google.firebase.messaging.default_notification_channel_id',
    )) {
      const metadata = """
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel" />
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@mipmap/ic_launcher" />""";

      if (content.contains('</activity>')) {
        content = content.replaceFirst('</activity>', '</activity>\n$metadata');
      }
    }
  }

  file.writeAsStringSync(content);
}

Future<void> _updateIosPlist(String pubspec, String activePath) async {
  final file = File(p.join(activePath, 'ios/Runner/Info.plist'));
  if (!file.existsSync()) return;

  printInfo('Updating Info.plist for iOS...');
  String content = file.readAsStringSync();

  if (pubspec.contains('firebase_messaging')) {
    if (!content.contains('FirebaseAppDelegateProxyEnabled')) {
      const pushConfig = """
	<key>FirebaseAppDelegateProxyEnabled</key>
	<false/>
	<key>UIBackgroundModes</key>
	<array>
		<string>fetch</string>
		<string>remote-notification</string>
	</array>
""";
      content = content.replaceFirst('</dict>', '$pushConfig</dict>');
    }
  }
  file.writeAsStringSync(content);
}

Future<void> _updateMacosEntitlements(String activePath) async {
  final paths = [
    'macos/Runner/DebugProfile.entitlements',
    'macos/Runner/Release.entitlements',
  ];
  for (final path in paths) {
    final file = File(p.join(activePath, path));
    if (file.existsSync()) {
      printInfo('Updating macOS entitlements: $path');
      String content = file.readAsStringSync();
      if (!content.contains('com.apple.security.network.client')) {
        content = content.replaceFirst(
          '</dict>',
          '\t<key>com.apple.security.network.client</key>\n\t<true/>\n\t<key>com.apple.security.network.server</key>\n\t<true/>\n</dict>',
        );
        file.writeAsStringSync(content);
      }
    }
  }
}

Future<void> _updateWindowsManifest(String activePath) async {
  // Usually standard in Flutter desktop templates
}

Future<void> _updateLinuxConfig(String activePath) async {
  // Linux setup for specific plugins if needed
}
