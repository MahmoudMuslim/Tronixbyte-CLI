import 'package:tools/tools.dart';

Future<void> windowsBuildWizard(List<String> commonArgs) async {
  if (!Platform.isWindows) {
    printError('Windows builds require a Windows host.');
    return;
  }

  printSection('Windows Build Wizard');
  final args = [...commonArgs];
  final modeStr =
      ask(
        'Build mode (debug/release/profile - default: release, "b" to back)',
      ) ??
      'release';
  if (modeStr.toLowerCase() == 'b') return;
  final mode = modeStr.toLowerCase();
  args.add('--$mode');

  if (mode != 'debug') {
    await addObfuscationArgs(args, 'windows');
    final analyze = (ask('Analyze build size? (y/n)') ?? 'n').toLowerCase();
    if (analyze == 'y') {
      args.add('--analyze-size');
    }
  }

  if ((ask('Tree shake icons? (y/n - default: y)') ?? 'y').toLowerCase() ==
      'n') {
    args.add('--no-tree-shake-icons');
  }

  await runCommand('flutter', [
    'build',
    'windows',
    ...args,
  ], loadingMessage: 'Building Windows Application ($mode)');
  printSuccess('Windows build completed successfully!');
  ask('Press Enter to return');
}

Future<void> macosBuildWizard(List<String> commonArgs) async {
  if (!Platform.isMacOS) {
    printError('MacOS builds require a macOS host.');
    return;
  }

  printSection('MacOS Build Wizard');
  final args = [...commonArgs];
  final modeStr =
      ask(
        'Build mode (debug/release/profile - default: release, "b" to back)',
      ) ??
      'release';
  if (modeStr.toLowerCase() == 'b') return;
  final mode = modeStr.toLowerCase();
  args.add('--$mode');

  if (mode != 'debug') {
    await addObfuscationArgs(args, 'macos');
  }

  if ((ask('Tree shake icons? (y/n - default: y)') ?? 'y').toLowerCase() ==
      'n') {
    args.add('--no-tree-shake-icons');
  }

  await runCommand('flutter', [
    'build',
    'macos',
    ...args,
  ], loadingMessage: 'Building MacOS Application ($mode)');
  printSuccess('MacOS build completed successfully!');
  ask('Press Enter to return');
}

Future<void> linuxBuildWizard(List<String> commonArgs) async {
  if (!Platform.isLinux) {
    printError('Linux builds require a Linux host.');
    return;
  }

  printSection('Linux Build Wizard');
  final args = [...commonArgs];
  final modeStr =
      ask(
        'Build mode (debug/release/profile - default: release, "b" to back)',
      ) ??
      'release';
  if (modeStr.toLowerCase() == 'b') return;
  final mode = modeStr.toLowerCase();
  args.add('--$mode');

  if ((ask('Tree shake icons? (y/n - default: y)') ?? 'y').toLowerCase() ==
      'n') {
    args.add('--no-tree-shake-icons');
  }

  await runCommand('flutter', [
    'build',
    'linux',
    ...args,
  ], loadingMessage: 'Building Linux Application ($mode)');
  printSuccess('Linux build completed successfully!');
  ask('Press Enter to return');
}
