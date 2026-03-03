import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> scaffoldShorebird() async {
  printSection('Shorebird Integration Scaffolder');

  final activePath = getActiveProjectPath();
  final projectName = await getProjectName();

  // runCommand already uses workingDirectory: activePath
  await runCommand('flutter', [
    'pub',
    'add',
    'shorebird_code_push',
  ], loadingMessage: 'Adding shorebird_code_push dependency');

  await loadingSpinner(
    'Generating Shorebird service and wiring injection in $activePath',
    () async {
      final serviceDir = Directory(
        p.join(activePath, 'lib', 'core', 'services'),
      );
      if (!serviceDir.existsSync()) serviceDir.createSync(recursive: true);

      final serviceFile = File(
        p.join(serviceDir.path, 'shorebird_service.dart'),
      );
      serviceFile.writeAsStringSync(getShorebirdServiceTemplate(projectName));

      // Use global barrel update utility
      updateServiceBarrel('shorebird_service.dart');

      final mainFile = File(p.join(activePath, 'lib', 'main.dart'));
      if (mainFile.existsSync()) {
        String content = mainFile.readAsStringSync();
        if (!content.contains('ShorebirdService.init()')) {
          content = content.replaceFirst(
            'WidgetsFlutterBinding.ensureInitialized();',
            'WidgetsFlutterBinding.ensureInitialized();\n\n  // Initialize Shorebird\n  await ShorebirdService.init();',
          );
          mainFile.writeAsStringSync(content);
          printInfo('Shorebird init added to ${mainFile.path}');
        }
      }
    },
  );

  printSuccess(
    'Shorebird scaffolding complete! Integrated into core services and main.dart in active project.',
  );
}
