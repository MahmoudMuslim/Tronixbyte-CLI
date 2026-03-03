import 'package:tools/tools.dart';

Future<void> promptCreateProject() async {
  while (true) {
    final options = ['Create New Flutter Project', 'Create New Dart Project'];

    final choice = selectOption('Create New Project', options, showBack: true);

    switch (choice) {
      case '1':
        await createFlutterProject();
        break;
      case '2':
        await createDartProject();
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
