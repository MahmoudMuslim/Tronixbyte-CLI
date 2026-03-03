String getStorageServiceTemplate() {
  return """
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
""";
}
