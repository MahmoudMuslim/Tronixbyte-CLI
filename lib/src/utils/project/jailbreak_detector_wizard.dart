import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runJailbreakDetectionWizard() async {
  printSection('🛡️ Root & Jailbreak Detection Wizard');

  final activePath = getActiveProjectPath();

  printInfo(
    'This tool will help you scaffold device integrity checks in $activePath.',
  );
  printInfo(
    'It integrates basic logic to detect rooted Android or jailbroken iOS devices.',
  );

  final confirm =
      (ask('Proceed with scaffolding detection logic? (y/n)') ?? 'n')
          .toLowerCase() ==
      'y';
  if (!confirm) return;

  await loadingSpinner(
    'Scaffolding security services in $activePath',
    () async {
      final projectName = await getProjectName();
      final serviceFile = File(
        p.join(activePath, 'lib/core/services/security_service.dart'),
      );

      if (!serviceFile.parent.existsSync()) {
        serviceFile.parent.createSync(recursive: true);
      }

      final content = getJailbreakDetectionWizardTemplate(projectName);

      serviceFile.writeAsStringSync(content.trim(), mode: FileMode.write);
      updateServiceBarrel('security_service.dart');
      await wireCoreInjection('SecurityService');
    },
  );

  printSuccess(
    'Jailbreak detection foundation scaffolded: lib/core/services/security_service.dart',
  );
  printInfo('👉 Registered in Dependency Injection (SecurityService).');
  printWarning(
    '👉 Recommendation: For robust production security, use the "flutter_jailbreak_detection" package.',
  );

  ask('Press Enter to return');
}
