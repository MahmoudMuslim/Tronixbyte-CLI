import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

/// Returns the absolute path of the currently selected active project.
String getActiveProjectPath() {
  final history = InputHistoryManager.getRecentInputs('active_project');
  if (history.isEmpty) {
    throw Exception(
      'No active project selected. Please use "Manage Existing Project" first.',
    );
  }
  return history.first;
}

/// Helper to check if a directory is a manageable project (and NOT the CLI tool itself).
bool isManageableProject(String path) {
  final pubspec = File(p.join(path, 'pubspec.yaml'));
  if (!pubspec.existsSync()) return false;
  try {
    final content = pubspec.readAsStringSync();
    final match = RegExp(r'name:\s+([^\s\n\r]+)').firstMatch(content);
    // Disallow managing the project named "tools" (this CLI itself)
    return match != null && match.group(1) != 'tools';
  } catch (_) {
    return false;
  }
}

/// Internal helper to set the active project context
void setProjectContext(String path) {
  final dir = Directory(path);
  if (dir.existsSync() && isManageableProject(path)) {
    InputHistoryManager.saveInput('active_project', dir.absolute.path);
    printSuccess('Project context set to: ${dir.absolute.path}');
  } else {
    printError('Invalid or restricted project path: $path');
    exit(1);
  }
}

Future<void> ensureProjectRoot() async {
  final activeHistory = InputHistoryManager.getRecentInputs('active_project');
  final createdHistory = InputHistoryManager.getRecentInputs('created_project');

  if (activeHistory.isNotEmpty) {
    final path = activeHistory.first;
    if (isManageableProject(path)) {
      return;
    } else {
      await InputHistoryManager.removeInput('active_project', path);
    }
  }

  final List<String> availableProjects = createdHistory
      .where((path) => isManageableProject(path))
      .toList();

  if (availableProjects.isEmpty) {
    printWarning('No manageable project found in history.');
    final path = ask('Please enter the Project absolute path');
    if (path != null) {
      setProjectContext(path);
    } else {
      printError('Project path is required. Exiting.');
      exit(1);
    }
    return;
  }

  final options = availableProjects.map((p) => 'Recent Project: $p').toList();
  options.add('Enter a new path');

  final choice = selectOption(
    'Select Project to Manage',
    options,
    showBack: false,
  );
  if (choice == null || choice == 'back') exit(0);

  final index = int.tryParse(choice) ?? 0;
  if (index > 0 && index <= availableProjects.length) {
    setProjectContext(availableProjects[index - 1]);
  } else if (index == options.length) {
    final path = ask('Please enter the Project absolute path');
    if (path != null) {
      setProjectContext(path);
    } else {
      printError('Project path is required. Exiting.');
      exit(1);
    }
  }
}

Future<String> getProjectName() async {
  final activePath = getActiveProjectPath();
  final pubspecFile = File(p.join(activePath, 'pubspec.yaml'));
  if (!pubspecFile.existsSync()) {
    throw Exception('pubspec.yaml not found in $activePath.');
  }
  final pubspecContent = pubspecFile.readAsStringSync();
  final nameMatch = RegExp(r'name:\s+([^\s\n\r]+)').firstMatch(pubspecContent);
  if (nameMatch == null) {
    throw Exception(
      'Could not find project name in pubspec.yaml at $activePath',
    );
  }
  return nameMatch.group(1)!;
}
