import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> generateReleaseNotes() async {
  printSection('📦 Automated Release Note Generator');

  final activePath = getActiveProjectPath();

  if (!Directory(p.join(activePath, '.git')).existsSync()) {
    printError(
      'Git repository not detected in $activePath. Cannot generate release notes from history.',
    );
    return;
  }

  final version =
      ask('Enter Version for these notes (e.g., 1.2.0)') ?? 'Unreleased';
  final List<String> features = [];
  final List<String> fixes = [];
  final List<String> others = [];

  await loadingSpinner('Extracting changes from Git history', () async {
    final result = await Process.run('git', [
      'log',
      '--oneline',
      '--pretty=format:%s',
      // We could limit to since last tag, but for simplicity we'll take last 50 commits
      '-n 50',
    ], workingDirectory: activePath);

    if (result.exitCode != 0) {
      throw Exception('Git log failed: ${result.stderr}');
    }

    final commits = result.stdout.toString().split('\n');
    for (final commit in commits) {
      final trimmed = commit.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.toLowerCase().startsWith('feat:')) {
        features.add(
          trimmed.replaceFirst(RegExp(r'feat:\s*', caseSensitive: false), ''),
        );
      } else if (trimmed.toLowerCase().startsWith('fix:')) {
        fixes.add(
          trimmed.replaceFirst(RegExp(r'fix:\s*', caseSensitive: false), ''),
        );
      } else {
        others.add(trimmed);
      }
    }
  });

  final buffer = StringBuffer();
  buffer.writeln('# 🚀 Release Notes - v$version');
  buffer.writeln(
    '\nGenerated on: ${DateTime.now().toString().split(' ')[0]}\n',
  );

  if (features.isNotEmpty) {
    buffer.writeln('### ✨ New Features');
    for (var f in features) {
      buffer.writeln('- $f');
    }
    buffer.writeln();
  }

  if (fixes.isNotEmpty) {
    buffer.writeln('### 🐛 Bug Fixes');
    for (var f in fixes) {
      buffer.writeln('- $f');
    }
    buffer.writeln();
  }

  if (others.isNotEmpty) {
    final includeOthers =
        (ask('Include ${others.length} uncategorized commits? (y/n)') ?? 'n')
            .toLowerCase() ==
        'y';
    if (includeOthers) {
      buffer.writeln('### 📝 Other Changes');
      for (var o in others) {
        buffer.writeln('- $o');
      }
      buffer.writeln();
    }
  }

  final fileName = 'RELEASE_NOTES.md';
  final filePath = p.join(activePath, fileName);
  File(filePath).writeAsStringSync(buffer.toString(), mode: FileMode.write);

  printSuccess(
    'Release notes generated successfully in active project: $fileName',
  );
  printInfo('👉 Tip: Review and polish the notes before sharing with users.');

  ask('Press Enter to return');
}
