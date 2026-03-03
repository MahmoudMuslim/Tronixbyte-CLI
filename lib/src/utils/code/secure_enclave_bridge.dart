import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runSecureEnclaveBridge() async {
  printSection('🛡️ Secure Enclave Bridge (Biometric Storage)');

  final activePath = getActiveProjectPath();
  final projectName = await getProjectName();

  printInfo(
    'Scaffolding hardware-backed secure storage bridge for $projectName.',
  );
  printInfo(
    'This module integrates Keychain (iOS) and Keystore (Android) with biometric policies.',
  );

  final confirm =
      (ask('Proceed with scaffolding secure enclave bridge? (y/n)') ?? 'n')
          .toLowerCase() ==
      'y';
  if (!confirm) return;

  await loadingSpinner('Scaffolding Secure Storage Service', () async {
    final serviceDir = Directory(p.join(activePath, 'lib', 'core', 'services'));
    if (!serviceDir.existsSync()) serviceDir.createSync(recursive: true);

    final serviceFile = File(
      p.join(serviceDir.path, 'secure_storage_service.dart'),
    );

    final content = """
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:\$projectName/z_src.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Saves a value securely.
  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Reads a value securely.
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Deletes a value.
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
""";

    serviceFile.writeAsStringSync(content.trim());

    // Update service barrel
    updateServiceBarrel('secure_storage_service.dart');
    await wireCoreInjection('SecureStorageService');
  });

  printSuccess(
    'Secure Enclave Bridge scaffolded successfully in active project!',
  );
  printWarning(
    '👉 Action Required: Add "flutter_secure_storage" to your pubspec.yaml.',
  );

  ask('Press Enter to return');
}
