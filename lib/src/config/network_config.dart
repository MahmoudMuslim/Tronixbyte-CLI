import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> configureNetwork(String projectName) async {
  printSection('Network & API Configuration');

  final activePath = getActiveProjectPath();

  // 1. Ensure dependencies are present
  await loadingSpinner('Ensuring network dependencies', () async {
    await runCommand('flutter', ['pub', 'add', ...apiDeps]);
    await runCommand('flutter', ['pub', 'add', '--dev', ...apiDevDeps]);
  });

  await loadingSpinner(
    'Scaffolding network and error handling layers',
    () async {
      final apiDir = Directory(p.join(activePath, 'lib', 'core', 'api'));
      if (!apiDir.existsSync()) apiDir.createSync(recursive: true);

      final errorDir = Directory(p.join(activePath, 'lib', 'core', 'errors'));
      if (!errorDir.existsSync()) errorDir.createSync(recursive: true);

      final networkDir = Directory(
        p.join(activePath, 'lib', 'core', 'network'),
      );
      if (!networkDir.existsSync()) networkDir.createSync(recursive: true);

      // 1. Create .env files
      _createEnvFiles(activePath);

      // 2. Generate ApiClient (Dio)
      final apiClientFile = File(p.join(apiDir.path, 'api_client.dart'));
      apiClientFile.writeAsStringSync(getApiClientTemplate(projectName));
      printInfo('Generated: ${apiClientFile.path}');

      // 3. Generate ApiService (Retrofit)
      final apiServiceFile = File(p.join(apiDir.path, 'api_service.dart'));
      apiServiceFile.writeAsStringSync(getApiServiceTemplate(projectName));
      printInfo('Generated: ${apiServiceFile.path}');

      // 4. Generate Failures
      final failureFile = File(p.join(errorDir.path, 'failures.dart'));
      failureFile.writeAsStringSync(getFailureTemplate(projectName));
      printInfo('Generated: ${failureFile.path}');

      // 5. Generate Network Info
      final networkInfoFile = File(
        p.join(networkDir.path, 'network_info.dart'),
      );
      networkInfoFile.writeAsStringSync(getNetworkInfoTemplate(projectName));
      printInfo('Generated: ${networkInfoFile.path}');

      // Update barrel files
      _updateBarrels(activePath);
    },
  );

  printSuccess(
    'Network foundation configured successfully in the active project!',
  );
  printInfo(
    '👉 Includes: Dio Client, Retrofit Service, Functional Failures, and Connectivity Monitoring.',
  );
  printInfo('👉 Remember to run build_runner to generate the .g.dart files.');
}

void _updateBarrels(String activePath) {
  File(
    p.join(activePath, 'lib', 'core', 'api', 'z_api.dart'),
  ).writeAsStringSync("export 'api_client.dart';\nexport 'api_service.dart';");
  File(
    p.join(activePath, 'lib', 'core', 'errors', 'z_errors.dart'),
  ).writeAsStringSync("export 'failures.dart';");
  File(
    p.join(activePath, 'lib', 'core', 'network', 'z_network.dart'),
  ).writeAsStringSync("export 'network_info.dart';");
}

void _createEnvFiles(String activePath) {
  final envs = {
    '.env.dev':
        'BASE_URL=https://dev-api.example.com/\nDEBUG=true\nENV=development',
    '.env.stg':
        'BASE_URL=https://stg-api.example.com/\nDEBUG=true\nENV=staging',
    '.env.prod':
        'BASE_URL=https://api.example.com/\nDEBUG=false\nENV=production',
    '.env':
        'BASE_URL=https://dev-api.example.com/\nDEBUG=true\nENV=development',
  };

  envs.forEach((path, content) {
    final file = File(p.join(activePath, path));
    if (!file.existsSync()) {
      file.writeAsStringSync(content);
      printInfo('Generated: $path');
    }
  });
}
