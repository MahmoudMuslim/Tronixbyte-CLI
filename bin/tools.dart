import 'package:tools/tools.dart';

void main(List<String> args) async {
  runZonedGuarded(
    () async {
      // 1. Initial Shortcut & CLI Argument Handling
      if (args.length >= 2) {
        // Direct Feature Generation: tools <name> <type>
        await ensureProjectRoot();
        await generateFeature(args[0].toLowerCase(), args[1].toLowerCase());
        return;
      }

      if (args.length == 1) {
        final cmd = args[0].toLowerCase();

        if (cmd == 'help') {
          _printHelp();
          return;
        }

        // Project-specific shortcuts require a context
        await ensureProjectRoot();
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
            await runLiveSecurityFeed();
            await runPerformanceAudit();
            return;
          case 'clean':
            await runCommand('flutter', ['clean']);
            await runCommand('flutter', ['pub', 'get']);
            return;
          case 'quality':
            await runCodeQualityTools();
            return;
          default:
            printError('Unknown command: $cmd');
            _printHelp();
            return;
        }
      }

      // 2. Main Interactive Loop
      while (true) {
        final options = [
          'Create New Project (Flutter/Dart)',
          'Manage Existing Project (Clean Architecture Tools)',
          'Clear History & Persistent Cache',
          'CLI Shortcuts & Documentation',
          'Exit',
        ];

        // selectOption handles banner and screen clearing
        final choice = selectOption('Main Menu', options, showBack: false);

        switch (choice) {
          case '1':
            await promptCreateProject();
            break;
          case '2':
            await manageProjectMenu();
            break;
          case '3':
            final confirm =
                (ask(
                          'Clear all history and project context? (y/n)',
                          defaultValue: 'n',
                        ) ??
                        'n')
                    .toLowerCase() ==
                'y';
            if (confirm) {
              await InputHistoryManager.clearAll();
              printSuccess('History cleared. Terminal context reset.');
            }
            break;
          case '4':
          case 'help':
            _printHelp();
            break;
          case '5':
            print('\n$green$bold👋 Goodbye from Tronixbyte CLI!$reset\n');
            exit(0);
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
  printInfo('Global command: "tools" (compiled .exe)');
  print('');

  printTable(
    ['Shortcut', 'Action / Description'],
    [
      ['tools <name> <type>', 'Generate a new Clean Arch feature'],
      ['tools sync', 'Synchronize dependencies, barrels, & code-gen'],
      ['tools repair', 'Nuclear architectural fix and re-wiring'],
      ['tools doctor', 'Deep health diagnosis and structural check'],
      ['tools stats', 'Real-time project complexity & LOC stats'],
      ['tools audit', 'Security, performance, & leak analysis'],
      ['tools clean', 'Project deep-clean and dependency refresh'],
      ['tools quality', 'Run formatting, analysis, and test suite'],
      ['tools help', 'Show this documentation'],
    ],
  );

  print(
    '\n$yellow$bold💡 PRO TIP:$reset Run these commands from any project subdirectory.',
  );
  ask('Press Enter to return');
}
