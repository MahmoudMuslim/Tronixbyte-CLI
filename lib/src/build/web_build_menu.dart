import 'package:tools/tools.dart';

Future<void> webBuildWizard(List<String> commonArgs) async {
  printSection('Flutter Web Build Wizard');
  final webArgs = [...commonArgs];

  final modeChoice = selectOption('Select Build Mode', [
    'Release (Default)',
    'Debug',
    'Profile',
  ], showBack: true);

  if (modeChoice == 'back' || modeChoice == null) return;

  String mode = 'release';
  if (modeChoice == '2') {
    mode = 'debug';
  } else if (modeChoice == '3') {
    mode = 'profile';
  }
  webArgs.add('--$mode');

  final useWasm =
      (ask('Compile to WebAssembly (WASM)? (y/n)', defaultValue: 'n') ?? 'n')
          .toLowerCase() ==
      'y';
  if (useWasm) {
    webArgs.add('--wasm');
    final stripWasm =
        (ask('Strip WASM symbols? (y/n)', defaultValue: 'y') ?? 'y')
            .toLowerCase() ==
        'y';
    if (!stripWasm) webArgs.add('--no-strip-wasm');
  }

  final baseHref = ask('Base href (e.g. /my_app/ - must start and end with /)');
  if (baseHref != null) webArgs.add('--base-href=$baseHref');

  final optLevel = ask('Optimization level (0-4)', defaultValue: '4');
  if (optLevel != null) webArgs.add('-O$optLevel');

  final disableSecurity =
      (ask('Disable web security? (y/n)', defaultValue: 'n') ?? 'n')
          .toLowerCase() ==
      'y';
  if (disableSecurity) {
    webArgs.addAll(['--web-browser-flag', '--disable-web-security']);
  }

  final treeShake =
      (ask('Tree shake icons? (y/n)', defaultValue: 'y') ?? 'y')
          .toLowerCase() ==
      'y';
  if (!treeShake) webArgs.add('--no-tree-shake-icons');

  final sourceMaps =
      (ask('Generate source maps? (y/n)', defaultValue: 'n') ?? 'n')
          .toLowerCase() ==
      'y';
  if (sourceMaps) webArgs.add('--source-maps');

  final csp =
      (ask('Enable CSP? (y/n)', defaultValue: 'n') ?? 'n').toLowerCase() == 'y';
  if (csp) webArgs.add('--csp');

  await runCommand(
    'flutter',
    ['build', 'web', ...webArgs],
    loadingMessage:
        'Building Flutter Web Application ($mode${useWasm ? ' + WASM' : ''})',
  );

  printSuccess('Web build completed successfully!');
  ask('Press Enter to return');
}
