import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> installGitHooks() async {
  printSection('Git Hooks Installer');

  final activePath = getActiveProjectPath();
  final gitDir = Directory(p.join(activePath, '.git'));

  if (!gitDir.existsSync()) {
    printError(
      '.git directory not found in $activePath. Please initialize git first.',
    );
    return;
  }

  final preCommitHook = getPreCommitHookTemplate();

  await loadingSpinner('Installing pre-commit hooks in $activePath', () async {
    try {
      final hooksDir = Directory(p.join(gitDir.path, 'hooks'));
      if (!hooksDir.existsSync()) hooksDir.createSync(recursive: true);

      final hookFile = File(p.join(hooksDir.path, 'pre-commit'));
      hookFile.writeAsStringSync(preCommitHook.trim());

      // On POSIX systems, ensure the hook is executable
      if (!Platform.isWindows) {
        await Process.run('chmod', ['+x', hookFile.path]);
      }
    } catch (e) {
      throw Exception('Failed to install Git hooks: \$e');
    }
  });

  printSuccess(
    'Git pre-commit hook installed successfully in the active project!',
  );
  printInfo(
    'Analysis and tests will now run automatically before every commit.',
  );
}
