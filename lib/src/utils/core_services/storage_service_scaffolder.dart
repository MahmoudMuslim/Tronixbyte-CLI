import 'package:tools/tools.dart';

Future<void> scaffoldStorageService() async {
  printSection('Storage Service Scaffolder');

  await runCommand('flutter', [
    'pub',
    'add',
    'flutter_secure_storage',
    'shared_preferences',
  ], loadingMessage: 'Adding storage dependencies');

  await loadingSpinner(
    'Generating StorageService and wiring injection',
    () async {
      final serviceFile = File('lib/core/services/storage_service.dart');
      if (!serviceFile.parent.existsSync()) {
        serviceFile.parent.createSync(recursive: true);
      }

      serviceFile.writeAsStringSync("""
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static const _secureStorage = FlutterSecureStorage();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Shared Preferences (General data) ---
  static Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  static String? getString(String key) => _prefs.getString(key);
  static Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  static bool? getBool(String key) => _prefs.getBool(key);
  static Future<bool> remove(String key) => _prefs.remove(key);

  // --- Secure Storage (Sensitive data like tokens) ---
  static Future<void> writeSecure(String key, String value) =>
      _secureStorage.write(key: key, value: value);
  static Future<String?> readSecure(String key) =>
      _secureStorage.read(key: key);
  static Future<void> deleteSecure(String key) =>
      _secureStorage.delete(key: key);
}
""");

      updateServiceBarrel('storage_service.dart');
      await wireCoreInjection('StorageService');
    },
  );

  printSuccess('StorageService ready!');
  printInfo('Use for both persistent settings and secure tokens.');
}
