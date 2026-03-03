import 'package:tools/tools.dart';

Future<bool> isFirebaseCliInstalled() async {
  try {
    final result = await Process.run(Platform.isWindows ? 'where' : 'which', [
      'firebase',
    ], runInShell: true);
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

Future<bool> isNpmInstalled() async {
  try {
    final result = await Process.run(Platform.isWindows ? 'where' : 'which', [
      'npm',
    ], runInShell: true);
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

Future<void> installNpm() async {
  printSection('Node.js (npm) Installation');

  if (Platform.isWindows) {
    if (await isCommandAvailable('winget')) {
      await runCommand('winget', [
        'install',
        'OpenJS.NodeJS',
      ], loadingMessage: 'Installing Node.js via winget');
    } else {
      printError(
        'winget not found. Please install Node.js manually: https://nodejs.org/',
      );
    }
  } else if (Platform.isMacOS) {
    if (await isCommandAvailable('brew')) {
      await runCommand('brew', [
        'install',
        'node',
      ], loadingMessage: 'Installing Node.js via brew');
    } else {
      printError(
        'brew not found. Please install Node.js manually: https://nodejs.org/',
      );
    }
  } else if (Platform.isLinux) {
    // Note: runCommand uses getActiveProjectPath() as workingDirectory
    await runCommand('sudo', ['apt', 'update'], loadingMessage: 'Updating apt');
    await runCommand('sudo', [
      'apt',
      'install',
      '-y',
      'nodejs',
      'npm',
    ], loadingMessage: 'Installing nodejs & npm');
  }

  printSuccess('Installation process finished.');
  printInfo('Please restart your terminal if the command is still not found.');
}

Future<bool> isCommandAvailable(String command) async {
  try {
    final result = await Process.run(Platform.isWindows ? 'where' : 'which', [
      command,
    ], runInShell: true);
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

Future<void> installFirebaseTools() async {
  printInfo('Installing firebase-tools via npm...');
  await runCommand('npm', [
    'install',
    '-g',
    'firebase-tools',
  ], loadingMessage: 'Running npm install');
  printSuccess('Firebase Tools installed successfully.');
}

Future<void> setupFlutterFire() async {
  printSection('FlutterFire CLI Setup');

  // runCommand already uses workingDirectory: getActiveProjectPath()
  await runCommand('dart', [
    'pub',
    'global',
    'activate',
    'flutterfire_cli',
  ], loadingMessage: 'Activating flutterfire_cli');

  printInfo('Running flutterfire configure...');
  await runCommand('flutterfire', ['configure']);
  printSuccess('FlutterFire CLI configured successfully.');
}
