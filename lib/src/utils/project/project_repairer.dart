import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> repairProject() async {
  printSection('Professional Project Repair');

  final activePath = getActiveProjectPath();
  final totalSteps = 8;

  // 1. Sync dependencies
  printStep(
    1,
    totalSteps,
    'Synchronizing dependencies (pub get) in $activePath',
  );
  // runCommand uses getActiveProjectPath() as workingDirectory internally
  await runCommand('flutter', [
    'pub',
    'get',
  ], loadingMessage: 'Fetching packages');

  // 2. Sync Global Exports
  printStep(2, totalSteps, 'Synchronizing lib/src/global.dart');
  await syncGlobalExports();

  // 3. Generate/Link Barrels
  printStep(3, totalSteps, 'Synchronizing Barrel Chain (z_*.dart)');
  await generateBarrelFiles();

  // 4. Generate Assets
  printStep(4, totalSteps, 'Generating asset constants');
  await generateAssetConstants();

  // 5. Re-wire Injections
  printStep(
    5,
    totalSteps,
    'Re-wiring feature injections in lib/injection.dart',
  );
  final featuresDir = Directory(p.join(activePath, 'lib', 'features'));
  if (featuresDir.existsSync()) {
    final features = featuresDir.listSync().whereType<Directory>();
    for (final feature in features) {
      final name = p.basename(feature.path);
      if (name.startsWith('z_')) continue;
      final namePascal = name[0].toUpperCase() + name.substring(1);
      // wireFeatureInjection is assumed to be project-aware (using activePath internally)
      await wireFeatureInjection(namePascal);
    }
  }

  // 6. Documentation
  printStep(6, totalSteps, 'Updating Features Overview (FEATURES.md)');
  await generateFeaturesOverview();

  // 7. Dashboard
  printStep(7, totalSteps, 'Generating Architectural Dashboard (STRUCTURE.md)');
  await generateProjectDashboard();

  // 8. Final Build
  printStep(8, totalSteps, 'Running final code generation (build_runner)');
  await runCommand('flutter', [
    'pub',
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ], loadingMessage: 'Generating code');

  print('\n');
  printSuccess(
    'Project repair complete! Everything is back in sync in active project.',
  );
}
