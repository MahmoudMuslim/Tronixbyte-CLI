import 'package:tools/tools.dart';

Future<void> switchEnvironment() async {
  printSection('Environment Switcher');

  final envs = ['dev', 'stg', 'prod'];
  for (var i = 0; i < envs.length; i++) {
    print(' $cyan${i + 1}:$reset ${envs[i].toUpperCase()}');
  }
  print(' $cyan${envs.length + 1}:$reset Back');

  final choice = ask('Select an environment (1-${envs.length + 1})');

  if (choice == null || choice == '${envs.length + 1}') return;

  final index = int.tryParse(choice);
  if (index == null || index < 1 || index > envs.length) {
    printError('Invalid option.');
    return;
  }

  final selectedEnv = envs[index - 1];
  final sourceFile = File('.env.$selectedEnv');
  final targetFile = File('.env');

  await loadingSpinner(
    'Switching to ${selectedEnv.toUpperCase()} environment',
    () async {
      if (!sourceFile.existsSync()) {
        printWarning('.env.$selectedEnv not found. Creating a template...');
        sourceFile.writeAsStringSync(
          'BASE_URL=https://api.$selectedEnv.example.com/\nDEBUG=true\nENV=$selectedEnv\n',
        );
      }

      targetFile.writeAsStringSync(sourceFile.readAsStringSync());
    },
  );

  printSuccess('Successfully switched to ${selectedEnv.toUpperCase()}!');
  printInfo(
    'Current .env now reflects ${selectedEnv.toUpperCase()} configuration.',
  );
}
