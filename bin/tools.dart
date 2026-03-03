import 'dart:async';

import 'package:tools/tools.dart';

void main(List<String> args) async {
  runZonedGuarded(
    () async {
      // Shortcut handling
      if (args.length >= 2) {
        await ensureProjectRoot();
        await generateFeature(args[0].toLowerCase(), args[1].toLowerCase());
        return;
      }

      if (args.length == 1) {
        await ensureProjectRoot();
        final cmd = args[0].toLowerCase();
        switch (cmd) {
          case 'sync':
            await syncProject();
            return;
          case 'repair':
            await repairProject();
            return;
          case 'stats':
            await showProjectStats();
            return;
          case 'doctor':
            await runProjectDoctor();
            return;
          case 'audit':
            await runSecurityAudit();
            await runPerformanceAudit();
            return;
          case 'clean':
            await runCommand('flutter', ['clean']);
            await runCommand('flutter', ['pub', 'get']);
            return;
          case 'quality':
            await runCodeQualityTools();
            return;
          case 'help':
            _printHelp();
            return;
        }
      }

      while (true) {
        final options = [
          'Create New Project (Flutter/Dart)',
          'Manage Existing Project (Clean Architecture Tools)',
          'Shortcuts & Help',
          'Exit',
        ];

        // selectOption already clears the console and prints the banner
        final choice = selectOption('Main Menu', options, showBack: false);

        switch (choice) {
          case '1':
            await promptCreateProject();
            break;
          case '2':
            await manageProjectMenu();
            break;
          case '3':
            _printHelp();
            break;
          case '4':
            print('\n$green$bold👋 Goodbye from Tronixbyte CLI!$reset\n');
            return;
          case null:
            break;
          default:
            printError('Invalid option.');
        }
      }
    },
    (error, stack) {
      print('\n$red$bold${'!' * 60}$reset');
      print('$red$bold 🚨 TRONIXBYTE CLI CRITICAL ERROR $reset');
      print('$red$bold${'!' * 60}$reset\n');
      printError('An unexpected error occurred: $error');
      printInfo('Please report this issue with the following stack trace:');
      print('\n$reset$stack');
      print('\n$red$bold${'!' * 60}$reset\n');
    },
  );
}

void _printHelp() {
  printSection('Tronixbyte CLI Shortcuts');
  printTable(
    ['Command', 'Description'],
    [
      ['dart bin/tools.dart <name> <type>', 'Generate a new feature'],
      ['dart bin/tools.dart sync', 'Full project sync'],
      ['dart bin/tools.dart repair', 'Deep project repair'],
      ['dart bin/tools.dart doctor', 'Project health diagnosis'],
      ['dart bin/tools.dart stats', 'Show project statistics'],
      ['dart bin/tools.dart audit', 'Security & performance audits'],
      ['dart bin/tools.dart clean', 'Flutter clean & get'],
      ['dart bin/tools.dart quality', 'Run code quality suite'],
      ['dart bin/tools.dart help', 'Show this help message'],
    ],
  );
  ask('Press Enter to return to Main Menu');
}
