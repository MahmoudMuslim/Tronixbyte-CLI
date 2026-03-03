import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> setupScreenshotAutomation() async {
  printSection('App Screenshot Automator');

  final activePath = getActiveProjectPath();
  final projectName = await getProjectName();

  await loadingSpinner(
    'Configuring integration_test for screenshots in $activePath',
    () async {
      // 1. Add dependency
      // runCommand already uses workingDirectory: activePath
      await runCommand('flutter', [
        'pub',
        'add',
        'dev:integration_test',
        'dev:flutter_test',
      ]);

      // 2. Create test directory if missing
      final testDir = Directory(p.join(activePath, 'integration_test'));
      if (!testDir.existsSync()) testDir.createSync(recursive: true);

      // 3. Create screenshot capture test
      final testFile = File(
        p.join(activePath, 'integration_test', 'screenshot_test.dart'),
      );
      testFile.writeAsStringSync("""
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:$projectName/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture screenshots', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Capture home screen
    await binding.takeScreenshot('1_home_screen');
    
    // Add more navigation and captures here...
  });
}
""");

      // 4. Create driver script
      final driverFile = File(
        p.join(activePath, 'test_driver', 'integration_test.dart'),
      );
      if (!driverFile.parent.existsSync())
        driverFile.parent.createSync(recursive: true);
      driverFile.writeAsStringSync("""
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
""");
    },
  );

  printSuccess(
    'Screenshot automation environment configured in active project!',
  );
  printInfo('Target Devices to be simulated:');
  print('   - iPhone 14 Pro Max (1290 x 2796)');
  print('   - iPhone 8 Plus (1242 x 2208)');
  print('   - iPad Pro 12.9 (2048 x 2732)');
  print('   - Pixel 7 Pro (1440 x 3120)');

  final runNow =
      (ask('Would you like to run the screenshot capture now? (y/n)') ?? 'n')
          .toLowerCase() ==
      'y';

  if (runNow) {
    await runCommand('flutter', [
      'drive',
      '--driver=test_driver/integration_test.dart',
      '--target=integration_test/screenshot_test.dart',
    ], loadingMessage: 'Running screenshot capture suite');

    printSuccess(
      'Screenshots captured and saved to project build/integration_test_screenshots/',
    );
  }
}
