import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> scaffoldNotificationService(String projectName) async {
  final activePath = getActiveProjectPath();
  printInfo('Scaffolding NotificationService in $activePath...');

  await loadingSpinner('Generating notification infrastructure', () async {
    final serviceFile = File(
      p.join(
        activePath,
        'lib',
        'core',
        'services',
        'notification_service.dart',
      ),
    );
    if (!serviceFile.parent.existsSync()) {
      serviceFile.parent.createSync(recursive: true);
    }

    serviceFile.writeAsStringSync(getNotificationServiceTemplate(projectName));

    // Use the global utility function
    updateServiceBarrel('notification_service.dart');
  });

  printSuccess('NotificationService scaffolded successfully.');
}
