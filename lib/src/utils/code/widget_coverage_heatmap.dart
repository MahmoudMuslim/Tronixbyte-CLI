import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runWidgetCoverageHeatmap() async {
  printSection('🧪 Widget Coverage Heatmap');

  final lcovFile = File('coverage/lcov.info');
  if (!lcovFile.existsSync()) {
    printWarning('coverage/lcov.info not found.');
    final runTests =
        (ask('Run unit/widget tests now to generate coverage? (y/n)') ?? 'n')
            .toLowerCase() ==
        'y';
    if (runTests) {
      await runCommand('flutter', [
        'test',
        '--coverage',
      ], loadingMessage: 'Generating coverage report');
    } else {
      return;
    }
  }

  if (!lcovFile.existsSync()) {
    printError('Failed to locate or generate lcov.info.');
    return;
  }

  final Map<String, List<int>> widgetStats = {}; // fileName -> [found, hit]

  await loadingSpinner('Analyzing widget test coverage density', () async {
    final lines = lcovFile.readAsLinesSync();
    String? currentFile;

    for (var line in lines) {
      if (line.startsWith('SF:')) {
        currentFile = line.substring(3).replaceAll('\\', '/');
      } else if (line.startsWith('LF:')) {
        final found = int.parse(line.substring(3));
        if (currentFile != null &&
            (currentFile.contains('/widgets/') ||
                currentFile.contains('/screens/'))) {
          widgetStats.putIfAbsent(currentFile, () => [0, 0])[0] += found;
        }
      } else if (line.startsWith('LH:')) {
        final hit = int.parse(line.substring(3));
        if (currentFile != null &&
            (currentFile.contains('/widgets/') ||
                currentFile.contains('/screens/'))) {
          widgetStats.putIfAbsent(currentFile, () => [0, 0])[1] += hit;
        }
      }
    }
  });

  if (widgetStats.isEmpty) {
    printInfo('No widget or screen coverage data found.');
    return;
  }

  final List<List<String>> rows = [];
  widgetStats.forEach((filePath, data) {
    final found = data[0];
    final hit = data[1];
    final percentage = found > 0 ? (hit / found * 100) : 0.0;

    // Create an ASCII heatmap bar
    final barLength = (percentage / 10).round();
    final bar = '█' * barLength + '░' * (10 - barLength);
    final color = percentage > 80 ? green : (percentage > 40 ? yellow : red);

    rows.add([
      p.basename(filePath),
      '$color$bar$reset',
      '${percentage.toStringAsFixed(1)}%',
      p.relative(filePath, from: Directory.current.path),
    ]);
  });

  // Sort by lowest coverage first to highlight issues
  rows.sort((a, b) {
    final aPerc = double.parse(a[2].replaceAll('%', ''));
    final bPerc = double.parse(b[2].replaceAll('%', ''));
    return aPerc.compareTo(bPerc);
  });

  print('\n$blue$bold🔥 WIDGET COVERAGE HEATMAP (Lowest First)$reset');
  printTable(['Widget/Screen', 'Heatmap', 'Coverage', 'Path'], rows);

  print('\n$cyan$bold💡 RECOMMENDATION$reset');
  if (rows.isNotEmpty) {
    final worst = rows.first;
    print(
      '   - Focus on testing "${worst[0]}" which has only ${worst[2]} coverage.',
    );
  }

  ask('Press Enter to return');
}
