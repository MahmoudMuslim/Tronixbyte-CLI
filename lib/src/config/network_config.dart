import 'package:tools/tools.dart';

Future<void> configureNetwork(String projectName) async {
  printSection('Network & API Configuration');

  // 1. Ensure dependencies are present
  await loadingSpinner('Ensuring network dependencies', () async {
    await runCommand('flutter', ['pub', 'add', ...apiDeps]);
    await runCommand('flutter', ['pub', 'add', '--dev', ...apiDevDeps]);
  });

  await loadingSpinner(
    'Scaffolding network and error handling layers',
    () async {
      final apiDir = Directory('lib/core/api');
      if (!apiDir.existsSync()) apiDir.createSync(recursive: true);

      final errorDir = Directory('lib/core/errors');
      if (!errorDir.existsSync()) errorDir.createSync(recursive: true);

      final networkDir = Directory('lib/core/network');
      if (!networkDir.existsSync()) networkDir.createSync(recursive: true);

      // 1. Generate ApiClient (Dio)
      final apiClientFile = File('lib/core/api/api_client.dart');
      apiClientFile.writeAsStringSync(getApiClientTemplate(projectName));
      printInfo('Generated: lib/core/api/api_client.dart');

      // 2. Generate ApiService (Retrofit)
      final apiServiceFile = File('lib/core/api/api_service.dart');
      apiServiceFile.writeAsStringSync(getApiServiceTemplate(projectName));
      printInfo('Generated: lib/core/api/api_service.dart');

      // 3. Generate Failures
      final failureFile = File('lib/core/errors/failures.dart');
      failureFile.writeAsStringSync(getFailureTemplate(projectName));
      printInfo('Generated: lib/core/errors/failures.dart');

      // 4. Generate Network Info
      final networkInfoFile = File('lib/core/network/network_info.dart');
      networkInfoFile.writeAsStringSync(getNetworkInfoTemplate(projectName));
      printInfo('Generated: lib/core/network/network_info.dart');

      // Update barrel files
      _updateBarrels();
    },
  );

  printSuccess('Network foundation configured successfully!');
  printInfo(
    '👉 Includes: Dio Client, Retrofit Service, Functional Failures, and Connectivity Monitoring.',
  );
  printInfo('👉 Remember to run build_runner to generate the .g.dart files.');
}

void _updateBarrels() {
  File(
    'lib/core/api/z_api.dart',
  ).writeAsStringSync("export 'api_client.dart';\nexport 'api_service.dart';");
  File(
    'lib/core/errors/z_errors.dart',
  ).writeAsStringSync("export 'failures.dart';");
  File(
    'lib/core/network/z_network.dart',
  ).writeAsStringSync("export 'network_info.dart';");
}
