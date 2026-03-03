import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> showProjectStats() async {
  printSection('Project Intelligence Dashboard');

  final activePath = getActiveProjectPath();
  final libDir = Directory(p.join(activePath, 'lib'));
  if (!libDir.existsSync()) {
    printError('lib directory not found at ${libDir.path}');
    return;
  }

  int totalFiles = 0;
  int totalLines = 0;
  int commentLines = 0;
  int blankLines = 0;
  int businessLogicLines = 0;
  int uiLines = 0;
  int totalFeatures = 0;
  int testLines = 0;
  int totalScreens = 0;
  int totalWidgets = 0;

  await loadingSpinner('Analyzing project structure and metrics', () async {
    final entities = libDir.listSync(recursive: true);
    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.dart')) {
        totalFiles++;
        final lines = entity.readAsLinesSync();
        totalLines += lines.length;

        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) {
            blankLines++;
          } else if (trimmed.startsWith('//') ||
              trimmed.startsWith('/*') ||
              trimmed.startsWith('*')) {
            commentLines++;
          }
        }

        // Layer categorization
        final path = entity.path.toLowerCase();
        if (path.contains('bloc') ||
            path.contains('cubit') ||
            path.contains('provider') ||
            path.contains('controller') ||
            path.contains('usecases') ||
            path.contains('repositories')) {
          businessLogicLines += lines.length;
        } else if (path.contains('presentation') ||
            path.contains('widgets') ||
            path.contains('screens')) {
          uiLines += lines.length;
        }

        if (path.contains('screens')) totalScreens++;
        if (path.contains('widgets')) totalWidgets++;
      } else if (entity is Directory && entity.path.contains('features')) {
        final rel = p.relative(entity.path, from: libDir.path);
        final parts = rel.split(Platform.pathSeparator);
        if (parts.length == 2 &&
            parts[0] == 'features' &&
            !parts[1].startsWith('z_')) {
          totalFeatures++;
        }
      }
    }

    // Test Metrics
    final testDir = Directory(p.join(activePath, 'test'));
    if (testDir.existsSync()) {
      final tests = testDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      for (final test in tests) {
        testLines += test.readAsLinesSync().length;
      }
    }
  });

  print('\n$blue$bold📊 CORE METRICS$reset');
  printTable(
    ['Metric', 'Value'],
    [
      ['Total Features', totalFeatures.toString()],
      ['Total Dart Files', totalFiles.toString()],
      ['Total Lines of Code (LOC)', totalLines.toString()],
      ['Total Test Lines', testLines.toString()],
      [
        'Code-to-Test Ratio',
        totalLines > 0 ? (testLines / totalLines).toStringAsFixed(2) : "0.00",
      ],
    ],
  );

  print('\n$blue$bold🧠 ARCHITECTURAL BREAKDOWN$reset');
  printTable(
    ['Layer', 'LOC', 'Percentage'],
    [
      [
        'Business Logic',
        businessLogicLines.toString(),
        totalLines > 0
            ? '${(businessLogicLines / totalLines * 100).toStringAsFixed(1)}%'
            : '0%',
      ],
      [
        'User Interface',
        uiLines.toString(),
        totalLines > 0
            ? '${(uiLines / totalLines * 100).toStringAsFixed(1)}%'
            : '0%',
      ],
      ['Screens', totalScreens.toString(), '-'],
      ['Widgets', totalWidgets.toString(), '-'],
      [
        'Comments',
        commentLines.toString(),
        totalLines > 0
            ? '${(commentLines / totalLines * 100).toStringAsFixed(1)}%'
            : '0%',
      ],
      [
        'Blank Lines',
        blankLines.toString(),
        totalLines > 0
            ? '${(blankLines / totalLines * 100).toStringAsFixed(1)}%'
            : '0%',
      ],
    ],
  );

  print('\n$blue$bold${'=' * 60}$reset');

  // Run Dependency Linter
  await checkFeatureDependencies();

  // Generate Visual Dashboard
  await generateProjectDashboard();

  printSuccess('Project statistics analysis complete!');
}
