import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runCodeMetrics() async {
  printSection('Code Metrics Analysis');

  final activePath = getActiveProjectPath();
  final libDir = Directory(p.join(activePath, 'lib'));

  if (!libDir.existsSync()) {
    printError('lib directory not found at ${libDir.path}.');
    return;
  }

  int totalFiles = 0;
  int totalLines = 0;
  int commentLines = 0;
  int blankLines = 0;
  int businessLogicLines = 0;
  int uiLines = 0;

  await loadingSpinner('Analyzing codebase metrics in $activePath', () async {
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

        final path = entity.path.toLowerCase();
        if (path.contains('bloc') ||
            path.contains('cubit') ||
            path.contains('provider') ||
            path.contains('controller')) {
          businessLogicLines += lines.length;
        } else if (path.contains('presentation') ||
            path.contains('widgets') ||
            path.contains('screens')) {
          uiLines += lines.length;
        }
      }
    }
  });

  print('\n$blue$bold📊 CORE METRICS$reset');
  printTable(
    ['Metric', 'Value'],
    [
      ['Total Dart Files', totalFiles.toString()],
      ['Total Lines of Code (LOC)', totalLines.toString()],
      [
        'Comment Lines',
        totalLines > 0
            ? '$commentLines (${(commentLines / totalLines * 100).toStringAsFixed(1)}%)'
            : '0',
      ],
      ['Blank Lines', blankLines.toString()],
    ],
  );

  print('\n$blue$bold🧠 ARCHITECTURAL RATIOS$reset');
  printTable(
    ['Category', 'LOC', 'Ratio'],
    [
      [
        'Business Logic',
        businessLogicLines.toString(),
        uiLines > 0 ? (businessLogicLines / uiLines).toStringAsFixed(2) : 'N/A',
      ],
      ['User Interface', uiLines.toString(), '1.00'],
    ],
  );

  printSuccess('Code metrics analysis complete!');
}
