import 'package:tools/tools.dart';

Future<void> scaffoldShorebird() async {
  printSection('Shorebird Integration Scaffolder');

  final projectName = await getProjectName();

  await runCommand('flutter', [
    'pub',
    'add',
    'shorebird_code_push',
  ], loadingMessage: 'Adding shorebird_code_push dependency');

  await loadingSpinner(
    'Generating Shorebird service and wiring injection',
    () async {
      final serviceDir = Directory('lib/core/services');
      if (!serviceDir.existsSync()) serviceDir.createSync(recursive: true);

      final serviceFile = File('lib/core/services/shorebird_service.dart');
      serviceFile.writeAsStringSync("""
import 'package:$projectName/$projectName.dart';

class ShorebirdService {
  static final ShorebirdCodePush _shorebirdCodePush = ShorebirdCodePush();

  static Future<void> init() async {
    if (kIsWeb) return;
    
    // Check for updates on startup
    final isUpdateAvailable = await _shorebirdCodePush.isNewPatchAvailableForDownload();
    if (isUpdateAvailable) {
      await _shorebirdCodePush.downloadUpdateIfAvailable();
    }
  }

  static Future<bool> isPatchAvailable() => _shorebirdCodePush.isNewPatchAvailableForDownload();
  
  static Future<void> downloadUpdate() => _shorebirdCodePush.downloadUpdateIfAvailable();
  
  static Future<int?> currentPatch() => _shorebirdCodePush.currentPatchNumber();
}
""");

      final barrelFile = File('lib/core/services/z_services.dart');
      final exportLine = "export 'shorebird_service.dart';\n";
      if (!barrelFile.existsSync()) {
        barrelFile.writeAsStringSync(exportLine);
      } else {
        String content = barrelFile.readAsStringSync();
        if (!content.contains('shorebird_service.dart')) {
          barrelFile.writeAsStringSync("$content$exportLine");
        }
      }

      final mainFile = File('lib/main.dart');
      if (mainFile.existsSync()) {
        String content = mainFile.readAsStringSync();
        if (!content.contains('ShorebirdService.init()')) {
          content = content.replaceFirst(
            'WidgetsFlutterBinding.ensureInitialized();',
            'WidgetsFlutterBinding.ensureInitialized();\n\n  // Initialize Shorebird\n  await ShorebirdService.init();',
          );
          mainFile.writeAsStringSync(content);
          printInfo('Shorebird init added to lib/main.dart');
        }
      }
    },
  );

  printSuccess(
    'Shorebird scaffolding complete! Integrated into core services and main.dart.',
  );
}
