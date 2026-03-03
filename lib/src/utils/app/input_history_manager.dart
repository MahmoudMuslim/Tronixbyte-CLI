import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

class InputHistoryManager {
  static String get _logPath {
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    return p.join(home ?? '.', '.tronix_input_history.json');
  }

  static Future<void> saveInput(String category, String value) async {
    if (value.isEmpty) return;

    final file = File(_logPath);
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

  static Future<void> removeInput(String category, String value) async {
    final file = File(_logPath);
    if (!file.existsSync()) return;

    Map<String, dynamic> history = {};
    try {
      history = json.decode(file.readAsStringSync());
    } catch (_) {
      return;
    }

    if (history.containsKey(category)) {
      final List<String> categoryList = List<String>.from(history[category]);
      if (categoryList.remove(value)) {
        history[category] = categoryList;
        file.writeAsStringSync(json.encode(history), mode: FileMode.write);
      }
    }
  }

  static List<String> getRecentInputs(String category) {
    final file = File(_logPath);
    if (!file.existsSync()) return [];
    try {
      final Map<String, dynamic> history = json.decode(file.readAsStringSync());
      return List<String>.from(history[category] ?? []);
    } catch (_) {
      return [];
    }
  }
}
