import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> createFlutterProject() async {
  printSection('Create New Flutter Project');

  final baseDir = ask('Base directory (Enter for current, "b" to back)') ?? '.';
  if (baseDir.toLowerCase() == 'b') return;

  String? projectName;
  while (projectName == null) {
    final name = ask('Project name (valid dart package name)');
    if (name == null) {
      printWarning('Project name is required.');
      continue;
    }
    if (_isValidDartPackageName(name)) {
      projectName = name;
    } else {
      printError(
        'Invalid project name. Must be lowercase, start with a letter, and contain only letters, numbers, and underscores.',
      );
    }
  }

  final projectPath = p.join(baseDir, projectName);

  final org = ask('Organization (e.g., com.example)') ?? 'com.example';
  final description = ask('Description') ?? 'A new Flutter project.';
  final androidLang = ask('Android language (java/kotlin)') ?? 'kotlin';
  final platformsInput = ask(
    'Platforms (comma-separated: ios,android,windows,linux,macos,web)',
  );
  final template =
      ask('Template (app,module,package,plugin,skeleton)') ?? 'app';
  final isEmpty = (ask('Empty template? (y/n)') ?? 'n').toLowerCase() == 'y';

  List<String> args = ['create', projectPath];
  args.addAll(['--project-name', projectName]);
  args.addAll(['--org', org]);
  args.addAll(['--description', description]);
  args.addAll(['--android-language', androidLang]);
  if (platformsInput != null) args.addAll(['--platforms', platformsInput]);
  args.addAll(['--template', template]);
  if (isEmpty) args.add('--empty');

  await runCommand('flutter', args, loadingMessage: 'Creating Flutter project');

  // Save the created project path
  final absolutePath = Directory(projectPath).absolute.path;
  InputHistoryManager.saveInput('created_project', absolutePath);

  printSuccess('Flutter project created successfully at $projectPath');
}

Future<void> createDartProject() async {
  printSection('Create New Dart Project');

  final baseDir = ask('Base directory (Enter for current, "b" to back)') ?? '.';
  if (baseDir.toLowerCase() == 'b') return;

  String? projectName;
  while (projectName == null) {
    final name = ask('Project name (valid dart package name)');
    if (name == null) {
      printWarning('Project name is required.');
      continue;
    }
    if (_isValidDartPackageName(name)) {
      projectName = name;
    } else {
      printError(
        'Invalid project name. Must be lowercase, start with a letter, and contain only letters, numbers, and underscores.',
      );
    }
  }

  final projectPath = p.join(baseDir, projectName);

  final template =
      ask('Template (cli,console,package,server-shelf,web)') ?? 'console';
  final force = (ask('Force generation? (y/n)') ?? 'n').toLowerCase() == 'y';

  List<String> args = ['create', '--template', template];
  if (force) args.add('--force');
  args.add(projectPath);

  await runCommand('dart', args, loadingMessage: 'Creating Dart project');

  // Save the created project path
  final absolutePath = Directory(projectPath).absolute.path;
  InputHistoryManager.saveInput('created_project', absolutePath);

  printSuccess('Dart project created successfully at $projectPath');
}

bool _isValidDartPackageName(String name) {
  // Dart package names must be lowercase, start with a letter or underscore,
  // and contain only alphanumeric characters and underscores.
  // Actually, standard recommendation is lowercase_with_underscores.
  final regex = RegExp(r'^[a-z][a-z0-9_]*$');
  return regex.hasMatch(name);
}
