String getJailbreakDetectionWizardTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

class SecurityService {
  static const MethodChannel _channel = MethodChannel('com.tronixbyte.security');

  /// Checks if the device is rooted or jailbroken.
  /// Note: Requires platform-specific implementation or a package like 'flutter_jailbreak_detection'.
  Future<bool> isDeviceCompromised() async {
    try {
      // Placeholder for actual detection logic
      // final bool isRooted = await _channel.invokeMethod('isRooted');
      // return isRooted;
      return false; 
    } catch (e) {
      debugPrint('Security check failed: \\\$e');
      return false;
    }
  }

  /// Verification for Production release
  void enforceDeviceIntegrity() async {
    if (kReleaseMode) {
      final compromised = await isDeviceCompromised();
      if (compromised) {
        // Handle compromised device (e.g., show alert and exit)
        debugPrint('🚨 DEVICE COMPROMISED: Application execution restricted.');
      }
    }
  }
}
""";
