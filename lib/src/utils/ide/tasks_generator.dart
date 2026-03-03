import 'package:tools/tools.dart';

Future<void> generateVsCodeTasks() async {
  printSection('VS Code Task Integration');

  final tasks = {
    "version": "2.0.0",
    "tasks": [
      {
        "label": "Tronixbyte: Sync Project",
        "type": "shell",
        "command": "dart bin/tools.dart",
        "args": ["sync"],
        "group": "build",
        "presentation": {"reveal": "always", "panel": "new"},
      },
      {
        "label": "Tronixbyte: Run Project Repair (Nuclear)",
        "type": "shell",
        "command": "dart bin/tools.dart",
        "args": ["repair"],
        "group": "none",
      },
      {
        "label": "Tronixbyte: Project Doctor (Diagnosis)",
        "type": "shell",
        "command": "dart bin/tools.dart",
        "args": ["doctor"],
        "group": "none",
      },
      {
        "label": "Tronixbyte: Security Audit",
        "type": "shell",
        "command": "dart bin/tools.dart",
        "args": ["audit"],
        "group": "none",
      },
      {
        "label": "Tronixbyte: Code Quality Suite",
        "type": "shell",
        "command": "dart bin/tools.dart",
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
        "command": "dart bin/tools.dart",
        "args": ["stats"],
      },
    ],
  };

  await loadingSpinner('Generating .vscode/tasks.json', () async {
    final vscodeDir = Directory('.vscode');
    if (!vscodeDir.existsSync()) vscodeDir.createSync();

    final file = File('.vscode/tasks.json');
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(tasks));
  });

  printSuccess('VS Code task integration generated successfully!');
  printInfo('Press Ctrl+Shift+B in VS Code to see your Tronixbyte tasks!');
}
