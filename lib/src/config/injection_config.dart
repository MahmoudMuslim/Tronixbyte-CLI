import 'package:tools/tools.dart';

Future<void> configureInjection(String projectName, String stateType) async {
  printSection('Dependency Injection Configuration');

  await loadingSpinner('Generating Dependency Injection root', () async {
    final injectionFile = File('lib/injection.dart');
    injectionFile.writeAsStringSync(
      getInjectionTemplate(projectName, stateType),
    );
  });

  printSuccess('lib/injection.dart generated successfully.');
  printInfo('Use "sl<YourService>()" to access dependencies across your app.');
}
