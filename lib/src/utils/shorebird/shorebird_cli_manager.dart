import 'package:tools/tools.dart';

class ShorebirdCliManager {
  static Future<bool> isInstalled() async {
    try {
      final result = await Process.run(Platform.isWindows ? 'where' : 'which', [
        'shorebird',
      ], runInShell: true);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  static Future<void> install() async {
    printSection('Shorebird CLI Installation');

    if (Platform.isWindows) {
      await runCommand('powershell', [
        '-Command',
        'Set-ExecutionPolicy RemoteSigned -scope CurrentUser -Force; iwr -UseBasicParsing https://raw.githubusercontent.com/shorebirdtech/install/main/install.ps1 | iex',
      ], loadingMessage: 'Installing Shorebird via PowerShell');
    } else {
      await runCommand('bash', [
        '-c',
        'curl -proto "=https" -tlsv1.2 -sSf https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh | bash',
      ], loadingMessage: 'Installing Shorebird via cURL');
    }

    printSuccess('Installation process completed.');
    printInfo(
      'Please restart your terminal if "shorebird" is not found immediately.',
    );
  }

  static Future<void> runDoctor() async {
    printSection('Shorebird Doctor');
    await runCommand('shorebird', ['doctor']);
  }

  static Future<void> upgrade() async {
    printSection('Shorebird Upgrade');
    await runCommand('shorebird', [
      'upgrade',
    ], loadingMessage: 'Upgrading Shorebird CLI');
    printSuccess('Shorebird CLI upgraded successfully.');
  }

  static Future<void> login() async {
    printSection('Shorebird Login');
    await runCommand('shorebird', ['login']);
  }
}
