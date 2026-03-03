import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> checkDependencies() async {
  printSection('Clean Architecture Dependency Guard');

  final featuresDir = Directory('lib/features');
  if (!featuresDir.existsSync()) {
    printWarning(
      'lib/features directory not found. Skipping architectural check.',
    );
    return;
  }

  int violations = 0;

  await loadingSpinner('Verifying architectural layer boundaries', () async {
    final features = featuresDir.listSync().whereType<Directory>();
    for (final feature in features) {
      final featureName = p.basename(feature.path);
      if (featureName.startsWith('z_')) continue;

      // Check Domain Layer (Should not depend on Data or Presentation)
      violations += _checkLayer(
        featurePath: p.join(feature.path, 'domain'),
        layerName: 'Domain',
        forbidden: ['data', 'presentation'],
        featureName: featureName,
      );

      // Check Data Layer (Should not depend on Presentation)
      violations += _checkLayer(
        featurePath: p.join(feature.path, 'data'),
        layerName: 'Data',
        forbidden: ['presentation'],
        featureName: featureName,
      );
    }
  });

  if (violations == 0) {
    printSuccess('No architectural violations found. Your project is clean!');
  } else {
    print('\n');
    printError('Found $violations architectural violations!');
    printInfo(
      'Please refactor your imports to follow Clean Architecture rules.',
    );
  }
}

int _checkLayer({
  required String featurePath,
  required String layerName,
  required List<String> forbidden,
  required String featureName,
}) {
  final dir = Directory(featurePath);
  if (!dir.existsSync()) return 0;

  int layerViolations = 0;
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    final lines = file.readAsLinesSync();
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.startsWith('import ')) {
        for (final forbiddenLayer in forbidden) {
          // Check for forbidden layer imports
          if (trimmedLine.contains('/$forbiddenLayer/') ||
              trimmedLine.contains('_$forbiddenLayer.dart')) {
            print(
              '\n   $red$bold🚨 Violation in $featureName [$layerName]:$reset',
            );
            print('      ${cyan}File:$reset ${p.relative(file.path)}');
            print('      ${cyan}Illegal Import:$reset $trimmedLine');
            layerViolations++;
          }
        }
      }
    }
  }
  return layerViolations;
}
