import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

class FeatureComplexity {
  final String name;
  final int loc;
  final int widgetCount;
  final int managerCount;
  final int dataCount;

  FeatureComplexity({
    required this.name,
    required this.loc,
    required this.widgetCount,
    required this.managerCount,
    required this.dataCount,
  });

  double get score =>
      (loc / 100) + (widgetCount * 2) + (managerCount * 5) + (dataCount * 3);
}

Future<void> runFeatureComplexityAudit() async {
  printSection('📊 Feature Complexity Auditor');

  final featuresDir = Directory('lib/features');
  if (!featuresDir.existsSync()) {
    printError('lib/features directory not found.');
    return;
  }

  final List<FeatureComplexity> complexities = [];

  await loadingSpinner(
    'Analyzing architectural depth and complexity',
    () async {
      final features = featuresDir.listSync().whereType<Directory>();

      for (final feature in features) {
        final name = p.basename(feature.path);
        if (name.startsWith('z_')) continue;

        int loc = 0;
        int widgetCount = 0;
        int managerCount = 0;
        int dataCount = 0;

        final files = feature
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in files) {
          final path = file.path.toLowerCase();
          final content = file.readAsLinesSync();
          loc += content.length;

          if (path.contains('presentation/widgets') ||
              path.contains('presentation/screens')) {
            widgetCount++;
          } else if (path.contains('manager') ||
              path.contains('bloc') ||
              path.contains('cubit')) {
            managerCount++;
          } else if (path.contains('data/')) {
            dataCount++;
          }
        }

        complexities.add(
          FeatureComplexity(
            name: name,
            loc: loc,
            widgetCount: widgetCount,
            managerCount: managerCount,
            dataCount: dataCount,
          ),
        );
      }
    },
  );

  complexities.sort((a, b) => b.score.compareTo(a.score));

  _showComplexityDashboard(complexities);
}

void _showComplexityDashboard(List<FeatureComplexity> complexities) {
  clearConsole();
  printBanner();
  printSection('Feature Complexity Dashboard');

  final List<List<String>> rows = complexities.map((c) {
    String status = '✅ Lean';
    if (c.score > 50) {
      status = '$red🚨 Bloated$reset';
    } else if (c.score > 25) {
      status = '$yellow⚠️ Moderate$reset';
    }

    return [
      c.name,
      c.loc.toString(),
      c.widgetCount.toString(),
      c.managerCount.toString(),
      status,
    ];
  }).toList();

  print('\n$blue$bold🚀 FEATURE COMPLEXITY RANKING$reset');
  printTable(['Feature', 'LOC', 'Widgets', 'Logic', 'Status'], rows);

  // Visual Distribution Chart (ASCII)
  print('\n$cyan$bold📊 COMPLEXITY DISTRIBUTION$reset');
  for (final c in complexities) {
    final barLength = (c.score).clamp(1, 40).toInt();
    final bar = '█' * barLength;
    final color = c.score > 50 ? red : (c.score > 25 ? yellow : green);
    print(
      '   ${c.name.padRight(15)} $color$bar$reset (${c.score.toStringAsFixed(1)})',
    );
  }

  print('\n$cyan$bold💡 ARCHITECTURAL ADVICE$reset');
  bool hadAdvice = false;
  for (final c in complexities) {
    if (c.score > 50) {
      print(
        '   - Feature "${c.name}" is too large (${c.loc} LOC). Consider splitting into sub-features.',
      );
      hadAdvice = true;
    }
    if (c.widgetCount > 15) {
      print(
        '   - Feature "${c.name}" has too many widgets ($c.widgetCount). Extract shared components.',
      );
      hadAdvice = true;
    }
  }
  if (!hadAdvice) {
    print('   - All features are currently within healthy limits.');
  }

  print('\n$blue$bold${'=' * 60}$reset');
  ask('Press Enter to return');
}
