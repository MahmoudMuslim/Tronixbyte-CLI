import 'package:tools/tools.dart';

class PathTracker {
  static const String _logFile = '.tronix_path_history.json';

  static Future<void> savePath(String path) async {
    if (path.isEmpty) return;

    // Check if it's actually a directory or file path to avoid saving random strings
    if (!Directory(path).existsSync() && !File(path).existsSync()) {
      return;
    }

    final file = File(_logFile);
    List<String> history = [];

    if (file.existsSync()) {
      try {
        history = List<String>.from(json.decode(file.readAsStringSync()));
      } catch (_) {}
    }

    // Remove if already exists to move to top
    history.remove(path);
    history.insert(0, path);

    // Keep only last 10 paths
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    file.writeAsStringSync(json.encode(history), mode: FileMode.write);
  }

  static List<String> getRecentPaths() {
    final file = File(_logFile);
    if (!file.existsSync()) return [];
    try {
      return List<String>.from(json.decode(file.readAsStringSync()));
    } catch (_) {
      return [];
    }
  }
}
