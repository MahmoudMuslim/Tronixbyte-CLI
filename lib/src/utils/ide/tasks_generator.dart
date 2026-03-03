import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> generateVsCodeTasks() async {
  printSection('VS Code Task Integration');

  final activePath = getActiveProjectPath();

  final tasks = {
    "version": "2.0.0",
    "tasks": [
      {
        "label": "Tronixbyte: Sync Project",
        "type": "shell",
        "command": "tools",
        "args": ["sync"],
        "group": "build",
        "presentation": {"reveal": "always", "panel": "new"},
      },
      {
        "label": "Tronixbyte: Run Project Repair (Nuclear)",
        "type": "shell",
        "command": "tools",
        "args": ["repair"],
        "group": "none",
      },
      {
        "label": "Tronixbyte: Project Doctor (Diagnosis)",
        "type": "shell",
        "command": "tools",
        "args": ["doctor"],
        "group": "none",
      },
      {
        "label": "Tronixbyte: Security Audit",
        "type": "shell",
        "command": "tools",
        "args": ["audit"],
        "group": "none",
      },
      {
        "label": "Tronixbyte: Code Quality Suite",
        "type": "shell",
        "command": "tools",
        "args": ["quality"],
        "group": "none",
      },
      {
        "label": "Tronixbyte: Build Runner (One-time)",
        "type": "shell",
        "command":
            "flutter pub run build_runner build --delete-conflicting-outputs",
        "group": "build",
      },
      {
        "label": "Tronixbyte: Build Runner (Watch)",
        "type": "shell",
        "command":
            "flutter pub run build_runner watch --delete-conflicting-outputs",
        "group": "none",
      },
      {
        "label": "Tronixbyte: Project Stats & Dashboard",
        "type": "shell",
        "command": "tools",
        "args": ["stats"],
      },
    ],
  };

  await loadingSpinner(
    'Generating .vscode/tasks.json in $activePath',
    () async {
      final vscodeDir = Directory(p.join(activePath, '.vscode'));
      if (!vscodeDir.existsSync()) vscodeDir.createSync(recursive: true);

      final file = File(p.join(vscodeDir.path, 'tasks.json'));
      file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(tasks));
    },
  );

  printSuccess('VS Code task integration generated successfully!');
  printInfo('Press Ctrl+Shift+B in VS Code to see your Tronixbyte tasks!');
}
