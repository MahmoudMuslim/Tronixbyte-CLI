import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> shorebirdReleaseWizard(String platform) async {
  printSection('Shorebird Release Wizard: ${platform.toUpperCase()}');

  final activePath = getActiveProjectPath();
  final List<String> args = ['release', platform];

  final useEnv =
      (ask('Use .env for dart-defines? (y/n)', defaultValue: 'n') ?? 'n')
          .toLowerCase() ==
      'y';
  if (useEnv) {
    final envType = (ask('Which env file? (dev/stg/prod)') ?? 'dev')
        .toLowerCase();
    final envFileName = '.env.$envType';
    final envPath = p.join(activePath, envFileName);

    if (File(envPath).existsSync()) {
      // Note: shorebird command expects the path relative to the project root
      // or we can pass the absolute path. Relative is usually fine as we run in workingDir.
      args.add('--dart-define-from-file=$envFileName');
    } else {
      printWarning(
        '$envFileName not found in project root. Proceeding without specific env file.',
      );
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

  // runCommand uses getActiveProjectPath() as workingDirectory internally
  await runCommand(
    'shorebird',
    args,
    loadingMessage: 'Creating $platform release on Shorebird',
  );

  printSuccess(
    'Shorebird release process completed for $platform in $activePath.',
  );
}
