import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

class PerformanceTracker {
  static String get _logPath {
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    return p.join(home ?? '.', '.tronix_perf_log.json');
  }

  static Future<void> logCommand(String command, double seconds) async {
    final file = File(_logPath);
    List<dynamic> logs = [];

    if (file.existsSync()) {
      try {
        logs = json.decode(file.readAsStringSync());
      } catch (_) {}
    }

    logs.add({
      'command': command,
      'duration': seconds,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Keep only last 100 logs
    if (logs.length > 100) {
      logs = logs.sublist(logs.length - 100);
    }

    file.writeAsStringSync(json.encode(logs), mode: FileMode.write);
  }

  static List<Map<String, dynamic>> getLogs() {
    final file = File(_logPath);
    if (!file.existsSync()) return [];
    try {
      return List<Map<String, dynamic>>.from(
        json.decode(file.readAsStringSync()),
      );
    } catch (_) {
      return [];
    }
  }
}
