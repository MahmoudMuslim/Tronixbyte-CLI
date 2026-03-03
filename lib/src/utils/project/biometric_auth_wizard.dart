import 'package:tools/tools.dart';

Future<void> runBiometricAuthWizard() async {
  printSection('🛡️ Advanced Biometric Auth Scaffolder');

  printInfo(
    'This tool will scaffold a production-ready Biometric Authentication service.',
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
    final serviceFile = File('lib/core/services/biometric_auth_service.dart');

    if (!serviceFile.parent.existsSync()) {
      serviceFile.parent.createSync(recursive: true);
    }

    final content =
        """
import 'package:local_auth/local_auth.dart';
import 'package:$projectName/$projectName.dart';

class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if the device supports any form of biometric authentication.
  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  /// Returns a list of available biometrics (e.g., face, fingerprint).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error fetching biometrics: \$e');
      return <BiometricType>[];
    }
  }

  /// Triggers the biometric authentication dialog.
  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to proceed',
    bool stickyAuth = true,
    bool biometricOnly = false,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      debugPrint('Biometric authentication error: \$e');
      return false;
    }
  }
}
""";

    serviceFile.writeAsStringSync(content.trim(), mode: FileMode.write);

    // Update core dependencies list for later synchronization
    // Note: User needs to run 'flutter pub add local_auth'

    updateServiceBarrel('biometric_auth_service.dart');
    await wireCoreInjection('BiometricAuthService');
  });

  printSuccess(
    'Biometric Auth Service scaffolded: lib/core/services/biometric_auth_service.dart',
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
