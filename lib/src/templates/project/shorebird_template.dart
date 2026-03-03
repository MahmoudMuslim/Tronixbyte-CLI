String getShorebirdServiceTemplate(String projectName) {
  return """
import 'package:$projectName/$projectName.dart';

class ShorebirdService {
static final ShorebirdCodePush _shorebirdCodePush = ShorebirdCodePush();

static Future<void> init() async {
  if (kIsWeb) return;
  
  // Check for updates on startup
  final isUpdateAvailable = await _shorebirdCodePush.isNewPatchAvailableForDownload();
  if (isUpdateAvailable) {
    await _shorebirdCodePush.downloadUpdateIfAvailable();
  }
}

static Future<bool> isPatchAvailable() => _shorebirdCodePush.isNewPatchAvailableForDownload();

static Future<void> downloadUpdate() => _shorebirdCodePush.downloadUpdateIfAvailable();

static Future<int?> currentPatch() => _shorebirdCodePush.currentPatchNumber();
}
""";
}
