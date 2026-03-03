import 'package:tools/tools.dart';

Future<void> installGitHooks() async {
  printSection('Git Hooks Installer');

  if (!Directory('.git').existsSync()) {
    printError('.git directory not found. Please initialize git first.');
    return;
  }

  final preCommitHook = """
#!/bin/sh
# Tronixbyte CLI - Pre-commit hook

echo "🔍 Running static analysis..."
flutter analyze
if [ \$? -ne 0 ]; then
  echo "❌ Analysis failed. Please fix issues before committing."
  exit 1
fi

echo "🧪 Running tests..."
flutter test
if [ \$? -ne 0 ]; then
  echo "❌ Tests failed. Please fix tests before committing."
  exit 1
fi

echo "✅ All checks passed. Committing..."
exit 0
""";

  await loadingSpinner('Installing pre-commit hooks', () async {
    try {
      final hooksDir = Directory('.git/hooks');
      if (!hooksDir.existsSync()) hooksDir.createSync(recursive: true);

      final hookFile = File('.git/hooks/pre-commit');
      hookFile.writeAsStringSync(preCommitHook.trim());

      // On Windows, we can't easily set executable permissions via File,
      // but Git Bash/WSL will respect it if we try via shell.
      if (!Platform.isWindows) {
        await Process.run('chmod', ['+x', '.git/hooks/pre-commit']);
      }
    } catch (e) {
      throw Exception('Failed to install Git hooks: $e');
    }
  });

  printSuccess('Git pre-commit hook installed successfully!');
  printInfo(
    'Analysis and tests will now run automatically before every commit.',
  );
}
