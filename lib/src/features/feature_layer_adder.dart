import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> promptAddFeatureLayer() async {
  printSection('Feature Layer Adder');

  final activePath = getActiveProjectPath();
  final name = ask('Feature Name to enhance (e.g., auth)');
  if (name == null || name.isEmpty) return;

  final featurePath = p.join(activePath, 'lib', 'features', name);
  if (!Directory(featurePath).existsSync()) {
    printError('Feature "$name" does not exist at $featurePath');
    return;
  }

  // Determine current logic type
  String type = 'cubit';
  if (Directory(p.join(featurePath, 'bloc')).existsSync()) {
    type = 'bloc';
  } else if (Directory(p.join(featurePath, 'controller')).existsSync()) {
    type = 'getx';
  } else if (Directory(p.join(featurePath, 'provider')).existsSync()) {
    final stateChoice = selectOption(
      'Logic folder found: /provider/. Select State Management type:',
      ['Riverpod', 'Provider'],
      showBack: false,
    );
    type = (stateChoice == '1') ? 'riverpod' : 'provider';
  }

  printInfo('Enhancing feature "$name" (Detected type: $type)');

  print('\n$blue$bold📦 Select Layers to Add:$reset');

  bool needData = (ask('Add Data Layer? (y/n)') ?? 'n').toLowerCase() == 'y';
  bool needDomain =
      (ask('Add Domain Layer? (y/n)') ?? 'n').toLowerCase() == 'y';
  bool needPresentation =
      (ask('Add Presentation Layer? (y/n)') ?? 'n').toLowerCase() == 'y';

  if (!needData && !needDomain && !needPresentation) {
    printInfo('No new layers selected. Skipping.');
    return;
  }

  bool needRoute = false;
  if (needPresentation) {
    needRoute = (ask('Add Route? (y/n)') ?? 'n').toLowerCase() == 'y';
  }

  final needTests =
      (ask('Generate Tests for new layers? (y/n)') ?? 'n').toLowerCase() == 'y';

  await loadingSpinner('Enhancing feature "$name"', () async {
    await generateFeature(
      name,
      type,
      needData: needData,
      needDomain: needDomain,
      needPresentation: needPresentation,
      needRoute: needRoute,
      needTests: needTests,
      overwrite: false, // Ensures we don't destroy existing code
    );
  });

  printSuccess('Feature "$name" enhanced successfully!');
}
