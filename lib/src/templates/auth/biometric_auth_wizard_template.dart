String getBiometricAuthWizardTemplate() => """
import 'package:local_auth/local_auth.dart';
import 'package:\$projectName/\$projectName.dart';

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
      debugPrint('Error fetching biometrics: \\\$e');
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
      debugPrint('Biometric authentication error: \\\$e');
      return false;
    }
  }
}
""";
