import 'package:tools/tools.dart';

class MetricsSnapshot {
  final int loc;
  final int assetCount;
  final DateTime timestamp;

  MetricsSnapshot({
    required this.loc,
    required this.assetCount,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'loc': loc,
    'assetCount': assetCount,
    'timestamp': timestamp.toIso8601String(),
  };

  factory MetricsSnapshot.fromJson(Map<String, dynamic> json) =>
      MetricsSnapshot(
        loc: json['loc'],
        assetCount: json['assetCount'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

Future<void> runGrowthForecaster() async {
  printSection('📈 Project Growth Forecaster');

  final logFile = File('.tronix_growth_log.json');
  List<MetricsSnapshot> history = [];

  if (logFile.existsSync()) {
    try {
      final List<dynamic> jsonList = json.decode(logFile.readAsStringSync());
      history = jsonList.map((e) => MetricsSnapshot.fromJson(e)).toList();
    } catch (_) {}
  }

  // 1. Capture Current Metrics
  int currentLoc = 0;
  int currentAssets = 0;

  await loadingSpinner('Capturing current project metrics', () async {
    // LOC check (simplified)
    final libDir = Directory('lib');
    if (libDir.existsSync()) {
      final files = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      for (final file in files) {
        currentLoc += file.readAsLinesSync().length;
      }
    }

    // Asset check
    final assetsDir = Directory('assets');
    if (assetsDir.existsSync()) {
      currentAssets = assetsDir
          .listSync(recursive: true)
          .whereType<File>()
          .length;
    }
  });

  // 2. Save Snapshot
  final now = DateTime.now();
  if (history.isEmpty || now.difference(history.last.timestamp).inHours >= 24) {
    history.add(
      MetricsSnapshot(
        loc: currentLoc,
        assetCount: currentAssets,
        timestamp: now,
      ),
    );
    if (history.length > 30) history.removeAt(0); // Keep last 30 days
    logFile.writeAsStringSync(
      json.encode(history.map((e) => e.toJson()).toList()),
    );
  }

  if (history.length < 2) {
    printInfo('Current Stats: $currentLoc LOC, $currentAssets Assets.');
    printWarning('Need at least 2 days of history to forecast trends.');
    return;
  }

  // 3. Forecast Logic (Linear Projection)
  final first = history.first;
  final last = history.last;
  final daysDiff = last.timestamp
      .difference(first.timestamp)
      .inDays
      .clamp(1, 365);

  final locGrowthPerDay = (last.loc - first.loc) / daysDiff;
  final assetGrowthPerDay = (last.assetCount - first.assetCount) / daysDiff;

  final loc30Days = (last.loc + (locGrowthPerDay * 30)).toInt();
  final assets30Days = (last.assetCount + (assetGrowthPerDay * 30)).toInt();

  // 4. Display Dashboard
  print('\n$blue$bold🚀 30-DAY GROWTH PROJECTION$reset');
  printTable(
    ['Metric', 'Current', 'Trend/Day', 'Predicted (30d)'],
    [
      [
        'Lines of Code',
        currentLoc.toString(),
        '+${locGrowthPerDay.toStringAsFixed(1)}',
        loc30Days.toString(),
      ],
      [
        'Asset Count',
        currentAssets.toString(),
        '+${assetGrowthPerDay.toStringAsFixed(1)}',
        assets30Days.toString(),
      ],
    ],
  );

  print('\n$cyan$bold📊 SCALE VISUALIZATION$reset');
  final maxLoc = loc30Days > 0 ? loc30Days : 1;
  print(
    '   [Now]       : ${'█' * ((currentLoc / maxLoc) * 40).toInt()} $currentLoc',
  );
  print('   [30 Days]   : ${'█' * 40} $loc30Days (Projected)');

  printSuccess('Forecasting complete!');
  ask('Press Enter to return');
}
