import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> switchEnvironment() async {
  printSection('Environment Switcher');

  final activePath = getActiveProjectPath();
  final envs = ['dev', 'stg', 'prod'];

  final options = envs.map((e) => e.toUpperCase()).toList();
  final choice = selectOption('Select Environment', options, showBack: true);

  if (choice == 'back' || choice == null) return;

  final index = int.tryParse(choice);
  if (index == null || index < 1 || index > envs.length) {
    printError('Invalid option.');
    return;
  }

  final selectedEnv = envs[index - 1];
  final sourceFile = File(p.join(activePath, '.env.$selectedEnv'));
  final targetFile = File(p.join(activePath, '.env'));

  await loadingSpinner(
    'Switching to ${selectedEnv.toUpperCase()} environment in $activePath',
    () async {
      if (!sourceFile.existsSync()) {
        printWarning(
          '.env.$selectedEnv not found in project. Creating a template...',
        );
        sourceFile.writeAsStringSync(
          'BASE_URL=https://api.$selectedEnv.example.com/\nDEBUG=true\nENV=$selectedEnv\n',
        );
      }

      targetFile.writeAsStringSync(sourceFile.readAsStringSync());
    },
  );

  printSuccess('Successfully switched to ${selectedEnv.toUpperCase()}!');
  printInfo(
    'Project .env now reflects ${selectedEnv.toUpperCase()} configuration.',
  );
}
