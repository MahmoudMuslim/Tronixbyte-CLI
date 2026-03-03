import 'package:tools/tools.dart';

Future<void> runGitFlowManager() async {
  while (true) {
    final options = [
      'Check current branch naming',
      'Initialize branch naming hook',
      'Generate PR Template',
      'Generate Changelog from Git History',
    ];

    final choice = selectOption(
      'Interactive Git Flow Manager',
      options,
      showBack: true,
    );

    if (choice == 'back' || choice == null) return;

    switch (choice) {
      case '1':
        await _checkBranchNaming();
        break;
      case '2':
        await _initBranchNamingHook();
        break;
      case '3':
        await _generatePrTemplate();
        break;
      case '4':
        await _generateGitChangelog();
        break;
      default:
        printError('Invalid option.');
    }

    if (choice != 'back') {
      ask('Press Enter to continue');
    }
  }
}

Future<void> _checkBranchNaming() async {
  await loadingSpinner('Checking branch name', () async {
    final result = await Process.run('git', [
      'rev-parse',
      '--abbrev-ref',
      'HEAD',
    ]);
    if (result.exitCode != 0) {
      printError('Git error: ${result.stderr}');
      return;
    }

    final branchName = result.stdout.toString().trim();
    final validPrefixes = [
      'feat/',
      'fix/',
      'chore/',
      'docs/',
      'refactor/',
      'perf/',
      'test/',
    ];

    bool isValid = validPrefixes.any((prefix) => branchName.startsWith(prefix));

    if (isValid) {
      printSuccess('Branch name "$branchName" follows conventions.');
    } else {
      printWarning('Branch name "$branchName" does NOT follow conventions.');
      printInfo('Recommended prefixes: ${validPrefixes.join(', ')}');
    }
  });
}

Future<void> _initBranchNamingHook() async {
  printSection('Branch Naming Hook Installer');

  if (!Directory('.git').existsSync()) {
    printError('.git directory not found.');
    return;
  }

  final hookContent = r'''
#!/bin/sh
local_branch_name="$(git rev-parse --abbrev-ref HEAD)"
valid_prefixes="feat/|fix/|chore/|docs/|refactor/|perf/|test/"
if ! echo "$local_branch_name" | grep -Eq "^($valid_prefixes)"; then
  echo "❌ Error: Invalid branch name '$local_branch_name'."
  echo "Branch names must start with: feat/, fix/, chore/, docs/, refactor/, perf/, or test/"
  exit 1
fi
''';

  await loadingSpinner('Installing branch naming hook', () async {
    final hookFile = File('.git/hooks/pre-push');
    if (!hookFile.parent.existsSync()) {
      hookFile.parent.createSync(recursive: true);
    }
    hookFile.writeAsStringSync(hookContent.trim(), mode: FileMode.write);

    if (!Platform.isWindows) {
      await Process.run('chmod', ['+x', '.git/hooks/pre-push']);
    }
  });

  printSuccess('Branch naming hook installed to .git/hooks/pre-push');
}

Future<void> _generatePrTemplate() async {
  await loadingSpinner('Generating PULL_REQUEST_TEMPLATE.md', () async {
    final template = """
## Description
<!-- Describe your changes in detail -->

## Type of Change
- [ ] Feature (New functionality)
- [ ] Fix (Bug fix)
- [ ] Refactor (Code improvement)
- [ ] Docs (Documentation)
- [ ] Chore (Maintenance)

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
""";

    final githubDir = Directory('.github');
    if (!githubDir.existsSync()) githubDir.createSync();

    File(
      '.github/PULL_REQUEST_TEMPLATE.md',
    ).writeAsStringSync(template.trim(), mode: FileMode.write);
  });

  printSuccess('Generated: .github/PULL_REQUEST_TEMPLATE.md');
}

Future<void> _generateGitChangelog() async {
  await loadingSpinner('Generating changelog from git history', () async {
    final result = await Process.run('git', [
      'log',
      '--oneline',
      '--pretty=format:%s',
    ]);
    if (result.exitCode != 0) {
      printError('Git error: ${result.stderr}');
      return;
    }

    final commits = result.stdout.toString().split('\n');
    final buffer = StringBuffer();
    buffer.writeln('# Changelog (Automated from Git)\n');

    for (final commit in commits) {
      if (commit.trim().isEmpty) continue;
      buffer.writeln('- $commit');
    }

    File(
      'GIT_CHANGELOG.md',
    ).writeAsStringSync(buffer.toString(), mode: FileMode.write);
  });

  printSuccess('Generated: GIT_CHANGELOG.md');
}
