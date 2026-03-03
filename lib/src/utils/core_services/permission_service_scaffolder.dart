import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> scaffoldPermissionService() async {
  printSection('Permission Service Scaffolder');

  final activePath = getActiveProjectPath();
  final servicePath = p.join(
    activePath,
    'lib/core/services/permission_service.dart',
  );

  if (File(servicePath).existsSync()) {
    printWarning('Permission Service already exists at $servicePath');
    return;
  }

  await runCommand('flutter', [
    'pub',
    'add',
    'permission_handler',
  ], loadingMessage: 'Adding permission_handler dependency');

  await loadingSpinner(
    'Generating PermissionService and wiring injection in $activePath',
    () async {
      final content = '''
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

class PermissionService {
  final Logger _logger = Logger();

  /// Request a specific permission
  Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isGranted) {
      _logger.i('Permission \${permission.toString()} granted.');
      return true;
    } else {
      _logger.w('Permission \${permission.toString()} denied.');
      return false;
    }
  }

  /// Check if a specific permission is granted
  Future<bool> isPermissionGranted(Permission permission) async {
    return await permission.isGranted;
  }

  /// Open app settings
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Request multiple permissions at once
  Future<Map<Permission, PermissionStatus>> requestMultiple(List<Permission> permissions) async {
    final statuses = await permissions.request();
    statuses.forEach((permission, status) {
      if (status.isGranted) {
        _logger.i('Permission \${permission.toString()} granted.');
      } else {
        _logger.w('Permission \${permission.toString()} \${status.toString()}.');
      }
    });
    return statuses;
  }
}
''';

      final file = File(servicePath);
      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }
      file.writeAsStringSync(content);

      updateServiceBarrel('permission_service.dart');
      await wireCoreInjection('PermissionService');
    },
  );

  printSuccess('PermissionService ready in active project!');
  printInfo(
    'Use via "sl<PermissionService>().requestPermission(Permission.camera)".',
  );
}
