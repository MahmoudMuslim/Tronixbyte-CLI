import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> configureProjectFlavors(String projectName) async {
  printSection('Multi-Flavor Configuration Wizard');

  final activePath = getActiveProjectPath();

  printInfo('This tool will configure "dev", "stg", and "prod" flavors.');
  printInfo(
    'Note: This performs deep modifications to Android and iOS build files.',
  );

  final confirm =
      (ask('Proceed with Flavor configuration? (y/n)') ?? 'n').toLowerCase() ==
      'y';
  if (!confirm) return;

  await loadingSpinner('Configuring Multi-Platform Flavors', () async {
    await _configureAndroidFlavors(projectName, activePath);
    await _configureIosFlavors(projectName, activePath);
    await _generateFlavorBaseCode(projectName, activePath);
  });

  printSuccess('Flavor configuration complete!');
  printInfo('👉 Run "flutter pub get" and check your build configurations.');
}

Future<void> _configureAndroidFlavors(
  String projectName,
  String activePath,
) async {
  final gradleFile = File(p.join(activePath, 'android', 'app', 'build.gradle'));
  if (!gradleFile.existsSync()) {
    printError('Android build.gradle not found at ${gradleFile.path}');
    return;
  }

  String content = gradleFile.readAsStringSync();

  if (content.contains('productFlavors')) {
    printWarning(
      'productFlavors already detected in build.gradle. Skipping injection.',
    );
    return;
  }

  final flavorConfig = getFlavorConfigTemplate(projectName);

  // Inject into android { ... } block
  final oldContent = content;
  content = content.replaceFirstMapped(
    RegExp(r'defaultConfig\s*\{[\s\S]*?\}'),
    (match) => '${match.group(0)}\n\n$flavorConfig',
  );
  if (content == oldContent) {
    printError('Could not locate the "defaultConfig" block in build.gradle.');
    printInfo(
      'Please ensure your build.gradle follows standard Flutter formatting.',
    );
    return;
  }
  gradleFile.writeAsStringSync(content, mode: FileMode.write);
}

Future<void> _configureIosFlavors(String projectName, String activePath) async {
  final iosFlutterDir = Directory(p.join(activePath, 'ios', 'Flutter'));
  if (!iosFlutterDir.existsSync()) return;

  final environments = ['Debug', 'Release', 'Profile'];
  final flavors = ['dev', 'stg', 'prod'];

  for (final flavor in flavors) {
    for (final env in environments) {
      final file = File(p.join(iosFlutterDir.path, '$env-$flavor.xcconfig'));
      file.writeAsStringSync(getFlavorConfigIOSTemplate(flavor, projectName));
    }
  }
}

Future<void> _generateFlavorBaseCode(
  String projectName,
  String activePath,
) async {
  final libDir = Directory(p.join(activePath, 'lib'));
  if (!libDir.existsSync()) return;

  // Generate entry points for each flavor
  final flavors = ['dev', 'stg', 'prod'];
  for (final flavor in flavors) {
    final entryFile = File(p.join(libDir.path, 'main_$flavor.dart'));
    entryFile.writeAsStringSync(getAppFlavorTemplate(projectName, flavor));
  }
}
