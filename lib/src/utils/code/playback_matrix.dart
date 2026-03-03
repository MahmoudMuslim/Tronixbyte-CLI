import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runPlaybackMatrix() async {
  printSection('🧪 Cross-Device Playback Matrix');

  final activePath = getActiveProjectPath();

  // 1. Discover integration tests
  final integrationTestDir = Directory(p.join(activePath, 'integration_test'));
  if (!integrationTestDir.existsSync()) {
    printError('No integration_test directory found in $activePath.');
    return;
  }

  final tests = integrationTestDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('_test.dart'))
      .toList();

  if (tests.isEmpty) {
    printWarning('No integration tests found.');
    return;
  }

  printInfo('Found ${tests.length} integration tests.');

  // 2. Discover connected devices
  final List<String> devices = [];
  await loadingSpinner('Detecting connected devices via ADB', () async {
    final result = await Process.run('adb', ['devices']);
    if (result.exitCode == 0) {
      final lines = result.stdout.toString().split('\n');
      for (var line in lines) {
        if (line.endsWith('device')) {
          devices.add(line.split('\t').first.trim());
        }
      }
    }
  });

  if (devices.isEmpty) {
    printError('No connected devices or emulators detected via ADB.');
    printInfo('Please connect a device or start an emulator.');
    return;
  }

  printInfo('Found ${devices.length} devices: ${devices.join(', ')}');

  final selectedTestIndex = selectOption(
    'Select Test to Playback',
    tests
        .map((f) => p.relative(f.path, from: integrationTestDir.path))
        .toList(),
    showBack: true,
  );

  if (selectedTestIndex == 'back' || selectedTestIndex == null) return;
  final testFile = tests[int.parse(selectedTestIndex) - 1];

  printWarning(
    'This will run the selected test across ALL detected devices sequentially.',
  );
  final confirm = (ask('Proceed? (y/n)') ?? 'n').toLowerCase() == 'y';
  if (!confirm) return;

  final List<List<String>> results = [];

  for (final deviceId in devices) {
    print('\n$cyan$bold▶️  PLAYBACK ON DEVICE: $deviceId$reset');

    final start = DateTime.now();
    // Use runCommand which targets the active project
    // Note: We need to pass the device id to flutter drive
    final exitCode = await runCommand('flutter', [
      'drive',
      '--driver=test_driver/integration_test.dart',
      '--target=${p.relative(testFile.path, from: activePath)}',
      '-d',
      deviceId,
    ], loadingMessage: 'Running test on $deviceId');

    final duration = DateTime.now().difference(start).inSeconds;
    results.add([
      deviceId,
      exitCode == 0 ? '✅ Passed' : '❌ Failed',
      '${duration}s',
    ]);
  }

  print('\n$blue$bold🏁 CROSS-DEVICE PLAYBACK SUMMARY$reset');
  printTable(['Device ID', 'Result', 'Time'], results);

  ask('Press Enter to return');
}
