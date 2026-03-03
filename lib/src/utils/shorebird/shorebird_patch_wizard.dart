import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> shorebirdPatchWizard(String platform) async {
  printSection('Shorebird Patch Wizard: ${platform.toUpperCase()}');

  final activePath = getActiveProjectPath();
  final List<String> args = ['patch', platform];

  final useEnv =
      (ask('Use .env for dart-defines? (y/n)') ?? 'n').toLowerCase() == 'y';
  if (useEnv) {
    final envType = (ask('Which env file? (dev/stg/prod)') ?? 'dev')
        .toLowerCase();
    final envFileName = '.env.$envType';
    final envPath = p.join(activePath, envFileName);

    if (File(envPath).existsSync()) {
      // Note: shorebird command might expect the relative path from the project root
      args.add('--dart-define-from-file=$envFileName');
    } else {
      printWarning(
        '$envFileName not found in project root. Proceeding without specific env file.',
      );
    }
  }

  final flavor = ask('Flavor (leave empty for none)');
  if (flavor != null) args.add('--flavor=$flavor');

  final releaseVersion = ask(
    'Specific release version to patch? (leave empty for latest)',
  );
  if (releaseVersion != null) args.add('--release-version=$releaseVersion');

  final dryRun = (ask('Dry run? (y/n)') ?? 'n').toLowerCase() == 'y';
  if (dryRun) args.add('--dry-run');

  // runCommand uses getActiveProjectPath() as workingDirectory internally
  await runCommand(
    'shorebird',
    args,
    loadingMessage: 'Pushing $platform patch to Shorebird',
  );

  printSuccess(
    'Shorebird patch process completed for $platform in $activePath.',
  );
}
