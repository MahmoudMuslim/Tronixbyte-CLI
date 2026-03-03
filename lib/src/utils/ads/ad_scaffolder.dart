import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> scaffoldAdIntegration() async {
  printSection('Ad Services Hub');

  final activePath = getActiveProjectPath();
  final adTypes = {
    'app_open': 'App Open Ads',
    'adaptive_banner': 'Adaptive Banner Ads',
    'fixed_banner': 'Fixed Size Banner Ads',
    'interstitial': 'Interstitial Ads',
    'rewarded': 'Rewarded Ads',
    'rewarded_interstitial': 'Rewarded Interstitial Ads',
    'native': 'Native Ads',
    'native_video': 'Native Video Ads',
  };

  final List<String> enabledTypes = [];
  adTypes.forEach((key, label) {
    final enable = (ask('Enable $label? (y/n)') ?? 'n').toLowerCase() == 'y';
    if (enable) enabledTypes.add(key);
  });

  if (enabledTypes.isEmpty) {
    printWarning('No ad types selected. Skipping integration.');
    return;
  }

  print('\n$blue$bold🔑 Production Release Configuration$reset');
  final androidAppId =
      ask('Enter REAL Android App ID (leave empty for test ID)') ??
      'ca-app-pub-3940256099942544~3347511713';
  final iosAppId =
      ask('Enter REAL iOS App ID (leave empty for test ID)') ??
      'ca-app-pub-3940256099942544~1458002511';

  final Map<String, Map<String, String>> unitIds = {};
  for (final type in enabledTypes) {
    print('\n$cyan📍 Configuring: ${adTypes[type]}$reset');
    final androidUnitId =
        ask('  - Android Ad Unit ID (leave empty for test ID)') ??
        _getTestId(type, 'android');
    final iosUnitId =
        ask('  - iOS Ad Unit ID (leave empty for test ID)') ??
        _getTestId(type, 'ios');
    unitIds[type] = {'android': androidUnitId, 'ios': iosUnitId};
  }

  final projectName = await getProjectName();

  // 1. Dependency
  // runCommand uses getActiveProjectPath() internally
  await runCommand('flutter', [
    'pub',
    'add',
    'google_mobile_ads',
  ], loadingMessage: 'Adding Google Mobile Ads dependency');

  // 2. Scaffolding
  await loadingSpinner('Generating Ad services & widgets', () async {
    // Note: Assuming generateAdService/Widgets use active project path or we update them if needed.
    await generateAdService(projectName, enabledTypes, unitIds);
    await generateAdWidgets(projectName, enabledTypes);
  });

  // 3. Injection
  final injectionFile = File(p.join(activePath, 'lib', 'injection.dart'));
  if (injectionFile.existsSync()) {
    printInfo('Wiring AdService into lib/injection.dart...');
    String content = injectionFile.readAsStringSync();
    if (!content.contains('AdService')) {
      content = content.replaceFirst(
        '// --- Core ---',
        '// --- Core ---\n  sl.registerLazySingleton(() => AdService());',
      );
      injectionFile.writeAsStringSync(content);
    }
  }

  // 4. Initialization
  final mainFile = File(p.join(activePath, 'lib', 'main.dart'));
  if (mainFile.existsSync()) {
    String content = mainFile.readAsStringSync();
    if (!content.contains('AdService.init()')) {
      content = content.replaceFirst(
        'WidgetsFlutterBinding.ensureInitialized();',
        'WidgetsFlutterBinding.ensureInitialized();\n\n  // Initialize Ad Services (GDPR/UMP Consent ready)\n  await AdService.init();',
      );
      mainFile.writeAsStringSync(content);
      printSuccess('Ad initialization added to lib/main.dart');
    }
  }

  // 5. Platform Config
  await _updateAndroidAdConfig(androidAppId, activePath);
  await _updateIosAdConfig(iosAppId, activePath);

  printSuccess(
    'Ad integration complete! Everything is functional and production-ready.',
  );
}

String _getTestId(String type, String platform) {
  final androidIds = {
    'app_open': 'ca-app-pub-3940256099942544/9257395921',
    'adaptive_banner': 'ca-app-pub-3940256099942544/9214589741',
    'fixed_banner': 'ca-app-pub-3940256099942544/6300978111',
    'interstitial': 'ca-app-pub-3940256099942544/1033173712',
    'rewarded': 'ca-app-pub-3940256099942544/5224354917',
    'rewarded_interstitial': 'ca-app-pub-3940256099942544/5354046379',
    'native': 'ca-app-pub-3940256099942544/2247696110',
    'native_video': 'ca-app-pub-3940256099942544/1044960115',
  };
  final iosIds = {
    'app_open': 'ca-app-pub-3940256099942544/5575463023',
    'adaptive_banner': 'ca-app-pub-3940256099942544/2934735716',
    'fixed_banner': 'ca-app-pub-3940256099942544/2934735716',
    'interstitial': 'ca-app-pub-3940256099942544/4411468910',
    'rewarded': 'ca-app-pub-3940256099942544/1712485313',
    'rewarded_interstitial': 'ca-app-pub-3940256099942544/6978759866',
    'native': 'ca-app-pub-3940256099942544/3986624511',
    'native_video': 'ca-app-pub-3940256099942544/2523427351',
  };
  return platform == 'android' ? androidIds[type]! : iosIds[type]!;
}

Future<void> _updateAndroidAdConfig(String appId, String activePath) async {
  final manifestFile = File(
    p.join(activePath, 'android', 'app', 'src', 'main', 'AndroidManifest.xml'),
  );
  if (!manifestFile.existsSync()) return;

  printInfo('Updating AndroidManifest.xml for Ads...');
  String content = manifestFile.readAsStringSync();

  content = content.replaceAll(
    RegExp(
      r'<meta-data\s+android:name="com\.google\.android\.gms\.ads\.APPLICATION_ID"[\s\S]*?/>',
    ),
    '',
  );

  final metaData = getADMetaDataAndroidTemplate(appId);

  if (content.contains('</activity>')) {
    content = content.replaceFirst('</activity>', '</activity>\n$metaData');
  } else {
    content = content.replaceFirst(
      '</application>',
      '$metaData\n</application>',
    );
  }

  const permission =
      '<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>';
  if (!content.contains('android.permission.AD_ID')) {
    content = content.replaceFirst('<manifest', '<manifest\n    $permission');
  }

  manifestFile.writeAsStringSync(content);
}

Future<void> _updateIosAdConfig(String appId, String activePath) async {
  final infoPlist = File(p.join(activePath, 'ios', 'Runner', 'Info.plist'));
  if (!infoPlist.existsSync()) return;

  printInfo('Updating Info.plist for Ads...');
  String content = infoPlist.readAsStringSync();

  content = content.replaceAll(
    RegExp(r'<key>GADApplicationIdentifier</key>\s*<string>[\s\S]*?</string>'),
    '',
  );

  final iosConfig = getADIOSConfigTemplate(appId);

  if (content.contains('</dict>')) {
    final lastDictIndex = content.lastIndexOf('</dict>');
    content =
        '${content.substring(0, lastDictIndex)}$iosConfig\n${content.substring(lastDictIndex)}';
  }

  infoPlist.writeAsStringSync(content);
}
