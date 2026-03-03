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

      final content = """
import 'package:flutter/services.dart';
import 'package:\$projectName/\$projectName.dart';

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
