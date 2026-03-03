import 'package:tools/tools.dart';

Future<void> scaffoldLoggerService() async {
  printSection('Logger Service Scaffolder');

  await runCommand('flutter', [
    'pub',
    'add',
    'logger',
  ], loadingMessage: 'Adding logger dependency');

  await loadingSpinner(
    'Generating LoggerService and wiring injection',
    () async {
      final serviceFile = File('lib/core/services/logger_service.dart');
      if (!serviceFile.parent.existsSync()) {
        serviceFile.parent.createSync(recursive: true);
      }

      serviceFile.writeAsStringSync("""
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    filter: kDebugMode ? DevelopmentFilter() : ProductionFilter());

  static void d(String message) => _logger.d(message);
  static void i(String message) => _logger.i(message);
  static void w(String message) => _logger.w(message);
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
""");

      updateServiceBarrel('logger_service.dart');
      await wireCoreInjection('LoggerService');
    },
  );

  printSuccess('LoggerService ready! Use via "LoggerService.i(\'message\')".');
}
