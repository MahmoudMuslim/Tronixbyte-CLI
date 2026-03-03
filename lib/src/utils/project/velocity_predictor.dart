import 'package:tools/tools.dart';

Future<void> runVelocityPredictor() async {
  printSection('📈 Project Velocity Predictor');

  if (!Directory('.git').existsSync()) {
    printError(
      'Git repository not detected. Velocity analysis requires Git history.',
    );
    return;
  }

  final List<DateTime> commitDates = [];
  int totalCommits = 0;

  await loadingSpinner('Analyzing Git commit velocity', () async {
    final result = await Process.run('git', ['log', '--pretty=format:%ai']);

    if (result.exitCode == 0) {
      final lines = result.stdout.toString().split('\n');
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          commitDates.add(DateTime.parse(line.trim()));
          totalCommits++;
        } catch (_) {}
      }
    }
  });

  if (commitDates.isEmpty) {
    printWarning('No commit history found to analyze.');
    return;
  }

  // 1. Calculate Velocity (Commits per week)
  final oldest = commitDates.last;
  final newest = commitDates.first;
  final ageInDays = newest.difference(oldest).inDays.clamp(1, 10000);
  final weeks = ageInDays / 7;
  final commitsPerWeek = totalCommits / weeks;

  // 2. Predict Release Date (Simplified model)
  // Assuming a "Standard Elite Project" target of 200 high-quality commits for a major release
  const targetCommits = 200;
  final remainingCommits = (targetCommits - totalCommits).clamp(
    0,
    targetCommits,
  );
  final estimatedWeeksToRelease = commitsPerWeek > 0
      ? remainingCommits / commitsPerWeek
      : 0.0;
  final predictedDate = DateTime.now().add(
    Duration(days: (estimatedWeeksToRelease * 7).toInt()),
  );

  // 3. Display Velocity Dashboard
  print('\n$blue$bold🚀 DEVELOPMENT VELOCITY DASHBOARD$reset');
  printTable(
    ['Metric', 'Value'],
    [
      ['Total Commits', totalCommits.toString()],
      ['Project Age', '$ageInDays days'],
      ['Velocity', '${commitsPerWeek.toStringAsFixed(1)} commits/week'],
      ['Predicted Release', predictedDate.toString().split(' ')[0]],
    ],
  );

  print('\n$cyan$bold📊 MOMENTUM VISUALIZATION$reset');
  // Simple momentum chart (commits in last 4 weeks)
  final now = DateTime.now();
  for (int i = 3; i >= 0; i--) {
    final weekStart = now.subtract(Duration(days: (i + 1) * 7));
    final weekEnd = now.subtract(Duration(days: i * 7));
    final weekCommits = commitDates
        .where((d) => d.isAfter(weekStart) && d.isBefore(weekEnd))
        .length;
    final bar = '█' * (weekCommits * 2).clamp(0, 40);
    print('   Week -${i}: $bar ($weekCommits)');
  }

  printSuccess('Velocity analysis complete!');
  ask('Press Enter to return');
}
