import 'package:tools/tools.dart';

Future<void> shorebirdReleaseWizard(String platform) async {
  printSection('Shorebird Release Wizard: ${platform.toUpperCase()}');
  final List<String> args = ['release', platform];

  final useEnv =
      (ask('Use .env for dart-defines? (y/n)') ?? 'n').toLowerCase() == 'y';
  if (useEnv) {
    final envType = (ask('Which env file? (dev/stg/prod)') ?? 'dev')
        .toLowerCase();
    final envPath = '.env.$envType';
    if (File(envPath).existsSync()) {
      args.add('--dart-define-from-file=$envPath');
    } else {
      printWarning('$envPath not found. Proceeding without specific env file.');
    }
  }

  final buildNumber = ask('Build Number (optional)');
  if (buildNumber != null) args.add('--build-number=$buildNumber');

  final buildName = ask('Build Name (optional, e.g. 1.0.0)');
  if (buildName != null) args.add('--build-name=$buildName');

  final flavor = ask('Flavor (leave empty for none)');
  if (flavor != null) args.add('--flavor=$flavor');

  if (platform == 'android') {
    final target = ask(
      'Target platform (android-arm, android-arm64, android-x64 - leave empty for all)',
    );
    if (target != null) args.add('--target-platform=$target');
  }

  final obfuscate = (ask('Obfuscate? (y/n)') ?? 'n').toLowerCase() == 'y';
  if (obfuscate) {
    args.add('--obfuscate');
    final splitDebug = ask('Split debug info path') ?? 'build/app/symbols';
    args.add('--split-debug-info=$splitDebug');
  }

  await runCommand(
    'shorebird',
    args,
    loadingMessage: 'Creating $platform release on Shorebird',
  );

  printSuccess('Shorebird release process completed for $platform.');
}
