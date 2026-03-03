import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> scaffoldStorageService() async {
  printSection('Storage Service Scaffolder');

  final activePath = getActiveProjectPath();

  await runCommand('flutter', [
    'pub',
    'add',
    'flutter_secure_storage',
    'shared_preferences',
  ], loadingMessage: 'Adding storage dependencies');

  await loadingSpinner(
    'Generating StorageService and wiring injection',
    () async {
      final serviceFile = File(
        p.join(activePath, 'lib/core/services/storage_service.dart'),
      );
      if (!serviceFile.parent.existsSync()) {
        serviceFile.parent.createSync(recursive: true);
      }

      serviceFile.writeAsStringSync(getStorageServiceTemplate());

      updateServiceBarrel('storage_service.dart');
      await wireCoreInjection('StorageService');
    },
  );

  printSuccess('StorageService ready in active project!');
  printInfo('Use for both persistent settings and secure tokens.');
}
