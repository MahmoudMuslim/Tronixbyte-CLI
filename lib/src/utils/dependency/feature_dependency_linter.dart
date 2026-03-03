import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<int> checkFeatureDependencies() async {
  printSection('Feature Isolation Linter');
  final featuresDir = Directory('lib/features');
  if (!featuresDir.existsSync()) {
    printWarning('lib/features directory not found. Skipping check.');
    return 0;
  }

  int violations = 0;
  final features = featuresDir
      .listSync()
      .whereType<Directory>()
      .where((d) => !p.basename(d.path).startsWith('z_'))
      .toList();

  await loadingSpinner('Analyzing cross-feature isolation boundaries', () async {
    for (final feature in features) {
      final featureName = p.basename(feature.path);
      final dartFiles = feature
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final lines = file.readAsLinesSync();
        for (final line in lines) {
          final trimmedLine = line.trim();
          if (trimmedLine.startsWith('import ')) {
            // Check if importing from another feature
            for (final otherFeature in features) {
              final otherName = p.basename(otherFeature.path);
              if (otherName == featureName) continue;

              final pattern = "/features/$otherName/";
              if (trimmedLine.contains(pattern)) {
                print(
                  '\n   $red$bold🚨 Violation in [$featureName]:$reset Imports from [$otherName]',
                );
                print('      ${cyan}File:$reset ${p.relative(file.path)}');
                print('      ${cyan}Line:$reset $trimmedLine');
                violations++;
              }
            }
          }
        }
      }
    }
  });

  if (violations == 0) {
    printSuccess(
      'Feature isolation is perfect! No cross-feature dependencies found.',
    );
  } else {
    print('\n');
    printWarning('Found $violations isolation violations.');
    printInfo(
      'Tip: Move shared logic/models between features to the "core" or "shared" layers.',
    );
  }

  return violations;
}
