import 'package:tools/tools.dart';

class InputHistoryManager {
  static const String _logFile = '.tronix_input_history.json';

  static Future<void> saveInput(String category, String value) async {
    if (value.isEmpty) return;

    // For path category, we still want to validate it's likely a path
    if (category == 'path' || category == 'directory') {
      if (!Directory(value).existsSync() && !File(value).existsSync()) {
        // If it's not an existing path, but it's a "path" prompt,
        // we might still want to save it if it looks like one, or just skip.
        // Let's be lenient for generic inputs.
      }
    }

    final file = File(_logFile);
    Map<String, dynamic> history = {};

    if (file.existsSync()) {
      try {
        history = json.decode(file.readAsStringSync());
      } catch (_) {}
    }

    final List<String> categoryList = List<String>.from(
      history[category] ?? [],
    );

    // Remove if already exists to move to top
    categoryList.remove(value);
    categoryList.insert(0, value);

    // Keep only last 5 entries per category to keep it clean
    if (categoryList.length > 5) {
      history[category] = categoryList.sublist(0, 5);
    } else {
      history[category] = categoryList;
    }

    file.writeAsStringSync(json.encode(history), mode: FileMode.write);
  }

  static List<String> getRecentInputs(String category) {
    final file = File(_logFile);
    if (!file.existsSync()) return [];
    try {
      final Map<String, dynamic> history = json.decode(file.readAsStringSync());
      return List<String>.from(history[category] ?? []);
    } catch (_) {
      return [];
    }
  }
}
