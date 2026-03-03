import 'package:tools/tools.dart';

Future<void> runMultiBuildHub() async {
  printSection('📦 Multi-Build Release Hub');

  final activePath = getActiveProjectPath();
  printInfo('Target Project: \$activePath');
  printInfo('Select the build targets you want to generate:');

  final Map<String, bool> targets = {
    'APK (Android)': false,
    'AAB (Android Bundle)': false,
    'IPA (iOS)': false,
    'Web Bundle': false,
  };

  for (final target in targets.keys) {
    targets[target] =
        (ask('Build \$target? (y/n)') ?? 'n').toLowerCase() == 'y';
  }

  if (!targets.values.any((selected) => selected)) {
    printInfo('No targets selected. Exiting.');
    return;
  }

  final List<List<String>> results = [];
  final totalSelected = targets.values.where((v) => v).length;
  int current = 0;

  await loadingSpinner(
    'Executing multi-platform build suite in \$activePath',
    () async {
      if (targets['APK (Android)']!) {
        current++;
        printStep(current, totalSelected, 'Building APK');
        final start = DateTime.now();
        // runCommand uses getActiveProjectPath() as workingDirectory internally
        await runCommand('flutter', [
          'build',
          'apk',
          '--release',
        ], loadingMessage: 'Compiling APK');
        results.add([
          'APK',
          '✅ Success',
          '\${DateTime.now().difference(start).inSeconds}s',
        ]);
      }

      if (targets['AAB (Android Bundle)']!) {
        current++;
        printStep(current, totalSelected, 'Building App Bundle');
        final start = DateTime.now();
        await runCommand('flutter', [
          'build',
          'appbundle',
          '--release',
        ], loadingMessage: 'Compiling AAB');
        results.add([
          'AAB',
          '✅ Success',
          '\${DateTime.now().difference(start).inSeconds}s',
        ]);
      }

      if (targets['IPA (iOS)']!) {
        current++;
        printStep(current, totalSelected, 'Building IPA');
        final start = DateTime.now();
        if (Platform.isMacOS) {
          await runCommand('flutter', [
            'build',
            'ipa',
            '--release',
          ], loadingMessage: 'Compiling IPA');
          results.add([
            'IPA',
            '✅ Success',
            '\${DateTime.now().difference(start).inSeconds}s',
          ]);
        } else {
          printWarning('IPA build skipped: Requires macOS.');
          results.add(['IPA', '⏩ Skipped', '-']);
        }
      }

      if (targets['Web Bundle']!) {
        current++;
        printStep(current, totalSelected, 'Building Web Bundle');
        final start = DateTime.now();
        await runCommand('flutter', [
          'build',
          'web',
          '--release',
        ], loadingMessage: 'Compiling Web');
        results.add([
          'Web',
          '✅ Success',
          '\${DateTime.now().difference(start).inSeconds}s',
        ]);
      }
    },
  );

  print('\n\$blue\$bold🏁 MULTI-BUILD RELEASE SUMMARY\$reset');
  printTable(['Target', 'Status', 'Time'], results);

  printSuccess('Release hub operation complete!');
  printInfo(
    '👉 Check the "build/" directory in \$activePath for your artifacts.',
  );

  ask('Press Enter to return');
}
