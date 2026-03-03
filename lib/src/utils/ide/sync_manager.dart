import 'package:tools/tools.dart';

Future<void> syncProject() async {
  printSection('Full Project Synchronization');
  final activePath = getActiveProjectPath();
  final totalSteps = 5;

  printStep(1, totalSteps, 'Running flutter pub get in $activePath');
  // runCommand uses getActiveProjectPath() internally
  await runCommand('flutter', [
    'pub',
    'get',
  ], loadingMessage: 'Updating dependencies');

  printStep(2, totalSteps, 'Generating barrel files (z_*.dart)');
  await generateBarrelFiles();
  await refreshBarrels();

  printStep(3, totalSteps, 'Running build_runner build');
  await runCommand('flutter', [
    'pub',
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ], loadingMessage: 'Generating code');

  printStep(4, totalSteps, 'Generating localization keys');
  await runCommand('dart', [
    'run',
    'easy_localization:generate',
    '-S',
    'assets/translations',
    '-f',
    'keys',
    '-o',
    'locale_keys.g.dart',
    '-O',
    'lib/l10n',
  ], loadingMessage: 'Updating translations');

  printStep(5, totalSteps, 'Formatting code');
  await runCommand('dart', [
    'format',
    '.',
  ], loadingMessage: 'Formatting project');

  print('\n');
  printSuccess('Project synchronized successfully!');
}
