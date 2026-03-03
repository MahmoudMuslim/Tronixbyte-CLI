import 'package:tools/tools.dart';

Future<void> coreServicesMenu() async {
  while (true) {
    final options = [
      'Scaffold Logger Service (Pretty Logging)',
      'Scaffold Network Service (Connectivity Monitoring)',
      'Scaffold Storage Service (Secure & Shared Prefs)',
      'Scaffold Permission Service (Dynamic Handler)',
      'Scaffold All Core Services',
    ];

    final choice = selectOption(
      'Core Services Management',
      options,
      showBack: true,
    );

    switch (choice) {
      case '1':
        await scaffoldLoggerService();
        break;
      case '2':
        await scaffoldNetworkService();
        break;
      case '3':
        await scaffoldStorageService();
        break;
      case '4':
        await scaffoldPermissionService();
        break;
      case '5':
        await scaffoldLoggerService();
        await scaffoldNetworkService();
        await scaffoldStorageService();
        await scaffoldPermissionService();
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
