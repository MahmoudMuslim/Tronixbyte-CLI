import 'package:tools/tools.dart';

Future<void> configureProjectFlavors(String projectName) async {
  printSection('Multi-Flavor Configuration Wizard');

  printInfo('This tool will configure "dev", "stg", and "prod" flavors.');
  printInfo(
    'Note: This performs deep modifications to Android and iOS build files.',
  );

  final confirm =
      (ask('Proceed with Flavor configuration? (y/n)') ?? 'n').toLowerCase() ==
      'y';
  if (!confirm) return;

  await loadingSpinner('Configuring Multi-Platform Flavors', () async {
    await _configureAndroidFlavors(projectName);
    await _configureIosFlavors(projectName);
    await _generateFlavorBaseCode(projectName);
  });

  printSuccess('Flavor configuration complete!');
  printInfo('👉 Run "flutter pub get" and check your build configurations.');
}

Future<void> _configureAndroidFlavors(String projectName) async {
  final gradleFile = File('android/app/build.gradle');
  if (!gradleFile.existsSync()) {
    printError('Android build.gradle not found.');
    return;
  }

  String content = gradleFile.readAsStringSync();

  if (content.contains('productFlavors')) {
    printWarning(
      'productFlavors already detected in build.gradle. Skipping injection.',
    );
    return;
  }

  final flavorConfig =
      """
    flavorDimensions "default"

    productFlavors {
        dev {
            dimension "default"
            resValue "string", "app_name", "$projectName (Dev)"
            applicationIdSuffix ".dev"
        }
        stg {
            dimension "default"
            resValue "string", "app_name", "$projectName (Stg)"
            applicationIdSuffix ".stg"
        }
        prod {
            dimension "default"
            resValue "string", "app_name", "$projectName"
        }
    }
""";

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

Future<void> _configureIosFlavors(String projectName) async {
  // iOS flavoring usually requires Xcode project manipulation (pbxproj)
  // For a CLI tool, we can scaffold the necessary config files (.xcconfig)
  final iosDir = Directory('ios/Flutter');
  if (!iosDir.existsSync()) return;

  final environments = ['Debug', 'Release', 'Profile'];
  final flavors = ['dev', 'stg', 'prod'];

  for (final flavor in flavors) {
    for (final env in environments) {
      final file = File('ios/Flutter/$env-$flavor.xcconfig');
      file.writeAsStringSync("""
#include "Generated.xcconfig"
#include "AppFrameworkInfo.xcconfig"

FLUTTER_TARGET=lib/main_$flavor.dart
ASSET_PREFIX=$flavor
APP_NAME=$projectName ${flavor.toUpperCase()}
""");
    }
  }
}

Future<void> _generateFlavorBaseCode(String projectName) async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) return;

  // Generate entry points for each flavor
  final flavors = ['dev', 'stg', 'prod'];
  for (final flavor in flavors) {
    final entryFile = File('lib/main_$flavor.dart');
    entryFile.writeAsStringSync("""
import 'package:$projectName/$projectName.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load flavor-specific .env
  await dotenv.load(fileName: '.env.$flavor');
  
  runApp(const App());
}
""");
  }
}
