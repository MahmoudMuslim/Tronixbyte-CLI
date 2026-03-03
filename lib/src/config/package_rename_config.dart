import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> configurePackageRename() async {
  printSection('Package Name & App Name Renaming');

  final activePath = getActiveProjectPath();
  final prSb = StringBuffer();
  final platforms = ['android', 'ios', 'linux', 'macos', 'web', 'windows'];

  for (final platform in platforms) {
    print('\n$cyan📍 Configuring: ${platform.toUpperCase()}$reset');
    final appName = ask('App Name');
    final packageName = ask('Package Name/ID (e.g., com.example.app)');

    if (appName != null || packageName != null) {
      prSb.writeln('$platform:');
      addField(prSb, 'app_name', appName, 1);
      addField(prSb, 'package_name', packageName, 1);

      if (platform == 'android') {
        addField(prSb, 'lang', ask('Language (kotlin/java)'), 1);
      }
      if (platform == 'ios') {
        addField(prSb, 'bundle_name', ask('Bundle Name'), 1);
      }
      if (platform == 'linux') {
        addField(prSb, 'exe_name', ask('Executable Name'), 1);
      }
      if (platform == 'macos') {
        addField(prSb, 'copyright_notice', ask('Copyright Notice'), 1);
      }
      if (platform == 'web') {
        addField(prSb, 'description', ask('Description'), 1);
      }
      if (platform == 'windows') {
        addField(prSb, 'organization', ask('Organization'), 1);
        addField(prSb, 'copyright_notice', ask('Copyright Notice'), 1);
        addField(prSb, 'exe_name', ask('Executable Name'), 1);
      }
    }
  }

  if (prSb.isNotEmpty) {
    await loadingSpinner(
      'Updating project package names and identities',
      () async {
        final configFile = File(
          p.join(activePath, 'package_rename_config.yaml'),
        );
        configFile.writeAsStringSync(prSb.toString());

        printInfo('Running package_rename script...');
        // runCommand uses getActiveProjectPath() as working directory
        await runCommand('dart', ['run', 'package_rename']);
      },
    );

    printSuccess(
      'Project successfully renamed across all configured platforms!',
    );
  } else {
    printInfo('No configurations provided. Skipping renaming process.');
  }
}
