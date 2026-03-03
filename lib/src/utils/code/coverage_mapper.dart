import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runFeatureCoverageAudit() async {
  printSection('📊 Feature-Level Code Coverage');

  final activePath = getActiveProjectPath();
  final lcovFile = File(p.join(activePath, 'coverage', 'lcov.info'));

  if (!lcovFile.existsSync()) {
    printWarning('coverage/lcov.info not found in $activePath.');
    final runTests =
        (ask('Run unit tests now to generate coverage? (y/n)') ?? 'n')
            .toLowerCase() ==
        'y';
    if (runTests) {
      // runCommand uses getActiveProjectPath() internally
      await runCommand('flutter', [
        'test',
        '--coverage',
      ], loadingMessage: 'Generating coverage report');
    } else {
      return;
    }
  }

  if (!lcovFile.existsSync()) {
    printError('Failed to locate or generate lcov.info at ${lcovFile.path}.');
    return;
  }

  final Map<String, List<int>> featureLines = {}; // featureName -> [found, hit]

  await loadingSpinner(
    'Mapping coverage to feature architecture in $activePath',
    () async {
      final lines = lcovFile.readAsLinesSync();
      String? currentFile;

      for (var line in lines) {
        if (line.startsWith('SF:')) {
          currentFile = line.substring(3).replaceAll('\\', '/');
        } else if (line.startsWith('LF:')) {
          final found = int.parse(line.substring(3));
          if (currentFile != null && currentFile.contains('/features/')) {
            final featureName = _extractFeatureName(currentFile);
            featureLines.putIfAbsent(featureName, () => [0, 0])[0] += found;
          }
        } else if (line.startsWith('LH:')) {
          final hit = int.parse(line.substring(3));
          if (currentFile != null && currentFile.contains('/features/')) {
            final featureName = _extractFeatureName(currentFile);
            featureLines.putIfAbsent(featureName, () => [0, 0])[1] += hit;
          }
        }
      }
    },
  );

  if (featureLines.isEmpty) {
    printInfo('No coverage data found for modular features.');
    return;
  }

  final List<List<String>> rows = [];
  featureLines.forEach((name, data) {
    final found = data[0];
    final hit = data[1];
    final percentage = found > 0 ? (hit / found * 100) : 0.0;

    String status = '🔴 Poor';
    if (percentage > 80) {
      status = '🟢 Elite';
    } else if (percentage > 50) {
      status = '🟡 Good';
    }

    rows.add([
      name,
      '$hit / $found',
      '${percentage.toStringAsFixed(1)}%',
      status,
    ]);
  });

  rows.sort((a, b) => b[2].compareTo(a[2]));

  print('\n$blue$bold🚀 FEATURE COVERAGE MAP$reset');
  printTable(['Feature', 'Lines (Hit/Total)', 'Coverage', 'Status'], rows);

  print('\n$cyan$bold💡 COVERAGE ADVICE$reset');
  featureLines.forEach((name, data) {
    final percentage = data[0] > 0 ? (data[1] / data[0] * 100) : 0.0;
    if (percentage < 50) {
      print(
        '   - Feature "$name" has critically low coverage (${percentage.toStringAsFixed(1)}%). Prioritize unit tests.',
      );
    }
  });

  ask('Press Enter to return');
}

String _extractFeatureName(String path) {
  final parts = path.split('/features/');
  if (parts.length < 2) return 'unknown';
  return parts[1].split('/').first;
}
