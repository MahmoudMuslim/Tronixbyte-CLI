import 'package:tools/tools.dart';

Future<void> runBuildRunner() async {
  printSection('Build Runner (One-time)');
  await runCommand('flutter', [
    'pub',
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ], loadingMessage: 'Generating files with Build Runner');
  printSuccess('Build Runner completed successfully.');
}

Future<void> watchBuildRunner() async {
  printSection('Build Runner (Watch Mode)');
  printInfo('Watching for changes... (Ctrl+C to stop)');
  // We don't use loadingSpinner here because watch is persistent
  await runCommand('flutter', [
    'pub',
    'run',
    'build_runner',
    'watch',
    '--delete-conflicting-outputs',
  ]);
}

Future<void> cleanAndBuildRunner() async {
  printSection('Clean & Build Runner');
  await runCommand('flutter', [
    'pub',
    'run',
    'build_runner',
    'clean',
  ], loadingMessage: 'Cleaning previous build artifacts');
  await runBuildRunner();
}
