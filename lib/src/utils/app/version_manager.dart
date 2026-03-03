import 'package:tools/tools.dart';

Future<void> manageVersion() async {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    printError('pubspec.yaml not found.');
    return;
  }

  String content = pubspecFile.readAsStringSync();
  final versionMatch = RegExp(r'version:\s+([^\s\n\r]+)').firstMatch(content);

  if (versionMatch == null) {
    printError('Could not find version in pubspec.yaml');
    return;
  }

  final currentFullVersion = versionMatch.group(1)!;
  printInfo('Current Version: $currentFullVersion');

  final parts = currentFullVersion.split('+');
  String version = parts[0];
  int build = parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;

  final options = [
    'Bump Patch (e.g., $version -> ${incrementVersion(version, 2)})',
    'Bump Minor (e.g., $version -> ${incrementVersion(version, 1)})',
    'Bump Major (e.g., $version -> ${incrementVersion(version, 0)})',
    'Custom Version',
    'Automated Release Sync (Build++)',
  ];

  final choice = selectOption(
    'Project Version Management',
    options,
    showBack: true,
  );

  if (choice == 'back' || choice == null) return;

  String newVersion = version;
  bool updateBuild = true;

  switch (choice) {
    case '1':
      newVersion = incrementVersion(version, 2);
      break;
    case '2':
      newVersion = incrementVersion(version, 1);
      break;
    case '3':
      newVersion = incrementVersion(version, 0);
      break;
    case '4':
      newVersion = ask('Enter new version (e.g., 1.2.3)') ?? version;
      break;
    case '5':
      updateBuild = true;
      break;
    default:
      printError('Invalid option.');
      return;
  }

  if (updateBuild) build++;
  final finalVersion = '$newVersion+$build';

  await loadingSpinner('Updating pubspec.yaml version', () async {
    content = content.replaceFirst(
      versionMatch.group(0)!,
      'version: $finalVersion',
    );
    pubspecFile.writeAsStringSync(content);
    _updateGlobalAppVersion(finalVersion);
  });

  printSuccess('Version updated to: $finalVersion');
}

String incrementVersion(String version, int index) {
  final vParts = version.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  while (vParts.length < 3) {
    vParts.add(0);
  }

  vParts[index]++;
  for (int i = index + 1; i < vParts.length; i++) {
    vParts[i] = 0;
  }
  return vParts.join('.');
}

void _updateGlobalAppVersion(String version) {
  final file = File('lib/core/constants/app_constants.dart');
  if (file.existsSync()) {
    String content = file.readAsStringSync();
    final versionRegex = RegExp(r"static const String appVersion = '[^']+';");
    if (versionRegex.hasMatch(content)) {
      content = content.replaceFirst(
        versionRegex,
        "static const String appVersion = '$version';",
      );
      file.writeAsStringSync(content);
      printInfo('Updated appVersion in lib/core/constants/app_constants.dart');
    }
  }
}
