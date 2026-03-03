import 'package:tools/tools.dart';

Future<void> buildAndReleaseMenu() async {
  while (true) {
    final options = [
      'Flutter Builds (Mobile, Web, Desktop)',
      'Dart Builds & Compilation (CLI, EXE, JS, WASM)',
      'Automated Release Note Generator (Git History)',
      'Multi-Build Release Hub (Parallel Suite)',
    ];

    final choice = selectOption('Build & Release Hub', options, showBack: true);

    switch (choice) {
      case '1':
        await flutterBuildMenu();
        break;
      case '2':
        await dartBuildMenu();
        break;
      case '3':
        await generateReleaseNotes();
        break;
      case '4':
        await runMultiBuildHub();
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
