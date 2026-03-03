import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> scaffoldLoggerService() async {
  printSection('Logger Service Scaffolder');

  final activePath = getActiveProjectPath();

  await runCommand('flutter', [
    'pub',
    'add',
    'logger',
  ], loadingMessage: 'Adding logger dependency');

  await loadingSpinner(
    'Generating LoggerService and wiring injection',
    () async {
      final serviceFile = File(
        p.join(activePath, 'lib/core/services/logger_service.dart'),
      );
      if (!serviceFile.parent.existsSync()) {
        serviceFile.parent.createSync(recursive: true);
      }

      serviceFile.writeAsStringSync(getLoggerServiceTemplate());

      updateServiceBarrel('logger_service.dart');
      await wireCoreInjection('LoggerService');
    },
  );

  printSuccess(
    'LoggerService ready in active project! Use via "LoggerService.i(\'message\')".',
  );
}

