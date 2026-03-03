import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runBiometricAuthWizard() async {
  printSection('🛡️ Advanced Biometric Auth Scaffolder');

  final activePath = getActiveProjectPath();

  printInfo(
    'This tool will scaffold a production-ready Biometric Authentication service in $activePath.',
  );
  printInfo(
    'It uses "local_auth" for FaceID, TouchID, and Fingerprint support.',
  );

  final confirm =
      (ask('Proceed with scaffolding biometric auth? (y/n)') ?? 'n')
          .toLowerCase() ==
      'y';
  if (!confirm) return;

  await loadingSpinner('Scaffolding Biometric Auth Service', () async {
    final projectName = await getProjectName();
    final serviceFile = File(
      p.join(activePath, 'lib/core/services/biometric_auth_service.dart'),
    );

    if (!serviceFile.parent.existsSync()) {
      serviceFile.parent.createSync(recursive: true);
    }

    final content = getBiometricAuthWizardTemplate(projectName);

    serviceFile.writeAsStringSync(content.trim(), mode: FileMode.write);

    // Update core dependencies list for later synchronization
    // Note: User needs to run 'flutter pub add local_auth'

    updateServiceBarrel('biometric_auth_service.dart');
    await wireCoreInjection('BiometricAuthService');
  });

  printSuccess(
    'Biometric Auth Service scaffolded successfully in active project!',
  );
  printInfo('👉 Registered in Dependency Injection (BiometricAuthService).');
  printWarning(
    '👉 Action Required: Run "flutter pub add local_auth" to install the dependency.',
  );
  printWarning('👉 iOS Note: Add NSFaceIDUsageDescription to your Info.plist.');
  printWarning(
    '👉 Android Note: Update your MainActivity to extend FlutterFragmentActivity.',
  );

  ask('Press Enter to return');
}
