import 'package:tools/tools.dart';
import 'package:path/path.dart' as p;

Future<void> generateChangelog() async {
  printSection('Professional Changelog Generator');

  final activePath = getActiveProjectPath();
  final file = File(p.join(activePath, 'CHANGELOG.md'));
  final version = await _getCurrentVersion(activePath);
  final date = DateTime.now().toString().split(' ').first;

  printInfo('Current Version: $version');

  final typeChoice = selectOption('Select update type', [
    'Feature (New functionality)',
    'Fix (Bug fixes)',
    'Breaking Change (API changes)',
  ], showBack: true);

  if (typeChoice == 'back' || typeChoice == null) return;

  final description = ask('Enter change description');
  if (description == null) return;

  String typeStr;
  switch (typeChoice) {
    case '2':
      typeStr = 'Fix';
      break;
    case '3':
      typeStr = 'Breaking';
      break;
    default:
      typeStr = 'Feature';
  }

  final entry = '- **$typeStr**: $description';

  await loadingSpinner('Updating CHANGELOG.md in $activePath', () async {
    String currentContent = '';
    if (file.existsSync()) {
      currentContent = file.readAsStringSync();
    }

    final header = '## [$version] - $date';

    if (currentContent.contains(header)) {
      final lines = currentContent.split('\n');
      final index = lines.indexOf(header);
      lines.insert(index + 1, entry);
      file.writeAsStringSync(lines.join('\n'));
    } else {
      // If file doesn't exist or doesn't start with header, create/prepend correctly
      if (!currentContent.startsWith('# Changelog')) {
        currentContent = '# Changelog\n\n$currentContent';
      }

      final insertionPoint =
          currentContent.indexOf('# Changelog') + '# Changelog'.length;
      final newContent =
          '${currentContent.substring(0, insertionPoint)}\n\n$header\n$entry${currentContent.substring(insertionPoint)}';

      file.writeAsStringSync('${newContent.trim()}\n');
    }
  });

  printSuccess('CHANGELOG.md updated successfully.');
}

Future<String> _getCurrentVersion(String activePath) async {
  final pubspec = File(p.join(activePath, 'pubspec.yaml'));
  if (!pubspec.existsSync()) return '1.0.0+1';
  final content = pubspec.readAsStringSync();
  final match = RegExp(r'version:\s+([^\s\n\r]+)').firstMatch(content);
  return match?.group(1) ?? '1.0.0+1';
}
