import 'package:tools/tools.dart';

Future<void> iosBuildWizard(List<String> commonArgs) async {
  if (!Platform.isMacOS) {
    printError('iOS builds require a macOS host.');
    return;
  }

  printSection('iOS Build Wizard');
  final iosArgs = [...commonArgs];

  final modeChoice = selectOption('Select Build Mode', [
    'Release (Default)',
    'Debug',
    'Profile',
  ], showBack: true);

  if (modeChoice == 'back' || modeChoice == null) return;

  String mode = 'release';
  if (modeChoice == '2') mode = 'debug';
  if (modeChoice == '3') mode = 'profile';
  iosArgs.add('--$mode');

  final codesign =
      (ask('Codesign? (y/n)', defaultValue: 'n') ?? 'n').toLowerCase() == 'y';
  if (!codesign) iosArgs.add('--no-codesign');

  final flavor = ask('Flavor/Scheme (leave empty for none)');
  if (flavor != null) iosArgs.add('--flavor=$flavor');

  final treeShake =
      (ask('Tree shake icons? (y/n)', defaultValue: 'y') ?? 'y')
          .toLowerCase() ==
      'y';
  if (!treeShake) iosArgs.add('--no-tree-shake-icons');

  await runCommand('flutter', [
    'build',
    'ios',
    ...iosArgs,
  ], loadingMessage: 'Building iOS Application ($mode)');
  printSuccess('iOS build completed successfully!');
  ask('Press Enter to return');
}
