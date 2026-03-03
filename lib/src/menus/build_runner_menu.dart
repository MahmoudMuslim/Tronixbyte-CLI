import 'package:tools/tools.dart';

Future<void> buildRunnerMenu() async {
  while (true) {
    final options = [
      'Run Build (One-time)',
      'Watch (Continuous generation)',
      'Clean & Build (Fix conflicts)',
    ];

    final choice = selectOption('Build Runner Tools', options, showBack: true);

    switch (choice) {
      case '1':
        await runBuildRunner();
        break;
      case '2':
        await watchBuildRunner();
        break;
      case '3':
        await cleanAndBuildRunner();
        break;
      case 'back':
        return;
      case null:
        break;
      default:
        printError('Invalid option.');
    }
  }
}
