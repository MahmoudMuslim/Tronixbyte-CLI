import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> scaffoldNetworkService() async {
  printSection('Network Service Scaffolder');

  final activePath = getActiveProjectPath();

  await runCommand('flutter', [
    'pub',
    'add',
    'connectivity_plus',
  ], loadingMessage: 'Adding connectivity_plus dependency');

  await loadingSpinner(
    'Generating NetworkService and wiring injection',
    () async {
      final serviceFile = File(
        p.join(activePath, 'lib/core/services/network_service.dart'),
      );
      if (!serviceFile.parent.existsSync()) {
        serviceFile.parent.createSync(recursive: true);
      }

      serviceFile.writeAsStringSync(getNetworkServiceTemplate());

      updateServiceBarrel('network_service.dart');
      await wireCoreInjection('NetworkService');
    },
  );

  printSuccess(
    'NetworkService ready in active project! Monitor connectivity reactively.',
  );
}
