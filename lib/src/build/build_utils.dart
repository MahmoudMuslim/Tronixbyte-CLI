import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

class BuildAbortException implements Exception {}

List<String> getCommonBuildArgs() {
  final List<String> args = [];
  final activePath = getActiveProjectPath();

  final useEnvStr = ask('Use .env for dart-defines? (y/n, "b" to back)') ?? 'n';
  if (useEnvStr.toLowerCase() == 'b') throw BuildAbortException();
  final useEnv = useEnvStr.toLowerCase() == 'y';

  if (useEnv) {
    final envType = (ask('Which env file? (dev/stg/prod)') ?? 'dev')
        .toLowerCase();
    final envPath = '.env.$envType';
    if (File(p.join(activePath, envPath)).existsSync()) {
      args.add('--dart-define-from-file=$envPath');
    } else {
      printWarning(
        '$envPath not found in the active project. Proceeding without it.',
      );
    }
  }

  final buildNumber = ask('Build Number (e.g., 1)');
  if (buildNumber != null) args.add('--build-number=$buildNumber');

  final buildName = ask('Build Name (e.g., 1.0.0)');
  if (buildName != null) args.add('--build-name=$buildName');

  final skipDep =
      (ask('Skip build dependency validation? (y/n)') ?? 'n').toLowerCase() ==
      'y';
  if (skipDep) args.add('--android-skip-build-dependency-validation');

  return args;
}

Future<void> addObfuscationArgs(List<String> args, String platform) async {
  final obfuscate =
      (ask('Obfuscate identifiers? (y/n)') ?? 'n').toLowerCase() == 'y';
  if (obfuscate) {
    args.add('--obfuscate');
    final defaultSplitPath = p.join('build', platform, 'symbols');
    final splitPath =
        ask('Split debug info path (default: $defaultSplitPath)') ??
        defaultSplitPath;
    args.add('--split-debug-info=$splitPath');
  }
}
