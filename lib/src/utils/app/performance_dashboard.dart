import 'package:tools/tools.dart';

Future<void> showPerformanceDashboard() async {
  printSection('📈 CLI Performance Dashboard');

  final logs = PerformanceTracker.getLogs();

  if (logs.isEmpty) {
    printInfo('No performance data recorded yet. Run some commands first!');
    return;
  }

  // 1. Calculate Averages per Command
  final Map<String, List<double>> cmdStats = {};
  for (final log in logs) {
    final cmd = log['command'] as String;
    final duration = log['duration'] as double;
    cmdStats.putIfAbsent(cmd, () => []).add(duration);
  }

  final List<List<String>> rows = [];
  cmdStats.forEach((cmd, durations) {
    final avg = durations.reduce((a, b) => a + b) / durations.length;
    final count = durations.length;
    rows.add([
      cmd.length > 40 ? '${cmd.substring(0, 37)}...' : cmd,
      count.toString(),
      '${avg.toStringAsFixed(2)}s',
    ]);
  });

  print('\n$blue$bold🚀 HISTORICAL COMMAND EFFICIENCY$reset');
  printTable(['Command/Task', 'Executions', 'Avg. Duration'], rows);

  // 2. Trend Analysis (Simple ASCII chart simulation)
  print('\n$cyan$bold📊 RECENT PERFORMANCE TREND (Last 10)$reset');
  final lastLogs = logs.length > 10 ? logs.sublist(logs.length - 10) : logs;
  for (final log in lastLogs) {
    final duration = log['duration'] as double;
    final bar = '█' * (duration * 5).clamp(1, 40).toInt();
    print('   ${log['duration'].toStringAsFixed(1)}s $bar');
  }

  print('\n$blue$bold${'=' * 60}$reset');
  printSuccess('Dashboard generated from global performance log.');
  ask('Press Enter to return');
}
