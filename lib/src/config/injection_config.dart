import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> configureInjection(String projectName, String stateType) async {
  printSection('Dependency Injection Configuration');

  final activePath = getActiveProjectPath();

  await loadingSpinner('Generating Dependency Injection root', () async {
    final injectionFile = File(p.join(activePath, 'lib', 'injection.dart'));

    // Ensure lib directory exists
    final libDir = Directory(p.join(activePath, 'lib'));
    if (!libDir.existsSync()) {
      libDir.createSync(recursive: true);
    }

    injectionFile.writeAsStringSync(
      getInjectionTemplate(projectName, stateType),
    );
  });

  printSuccess(
    'lib/injection.dart generated successfully in the active project.',
  );
  printInfo('Use "sl<YourService>()" to access dependencies across your app.');
}
