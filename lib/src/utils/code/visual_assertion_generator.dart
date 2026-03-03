import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runVisualAssertionGenerator() async {
  printSection('🧪 Visual Assertion Engine (ADB Integrated)');

  final activePath = getActiveProjectPath();

  printInfo(
    'This tool uses ADB to capture the UI state from your connected device and generate assertions.',
  );
  printInfo('Please ensure your app is running on the target screen.');

  final confirm =
      (ask('Is the device connected and screen ready? (y/n)') ?? 'n')
          .toLowerCase() ==
      'y';
  if (!confirm) return;

  await loadingSpinner('Capturing UI hierarchy via ADB', () async {
    try {
      final xmlPath = p.join(activePath, 'view.xml');

      // 1. Dump UI to device
      final dumpResult = await Process.run('adb', [
        'shell',
        'uiautomator',
        'dump',
        '/sdcard/view.xml',
      ]);

      if (dumpResult.exitCode != 0) {
        throw Exception(
          'Failed to dump UI. Ensure ADB is in your PATH and a device is connected.',
        );
      }

      // 2. Pull XML to local
      final pullResult = await Process.run('adb', [
        'pull',
        '/sdcard/view.xml',
        xmlPath,
      ]);

      if (pullResult.exitCode != 0) throw Exception('Failed to pull UI dump.');

      final xmlFile = File(xmlPath);
      final content = xmlFile.readAsStringSync();

      // 3. Extract Text and Resource IDs using Regex
      final textRegex = RegExp(r'text="([^"]+)"');
      final idRegex = RegExp(r'resource-id="([^"]+)"');

      final texts = textRegex
          .allMatches(content)
          .map((m) => m.group(1))
          .where((t) => t != null && t.trim().isNotEmpty)
          .toSet()
          .toList();

      final ids = idRegex
          .allMatches(content)
          .map((m) => m.group(1))
          .where((id) => id != null && id.trim().isNotEmpty)
          .toSet()
          .toList();

      final buffer = StringBuffer();
      buffer.writeln('// --- AUTO-GENERATED ASSERTIONS ---');
      buffer.writeln('// Captured at: ${DateTime.now()}');
      buffer.writeln('');

      if (texts.isNotEmpty) {
        buffer.writeln('// Text Assertions');
        for (final text in texts) {
          buffer.writeln("expect(find.text('$text'), findsOneWidget);");
        }
        buffer.writeln('');
      }

      if (ids.isNotEmpty) {
        buffer.writeln('// Resource ID Assertions');
        for (final id in ids) {
          final keyName = id!.split('/').last;
          buffer.writeln(
            "expect(find.byKey(const Key('$keyName')), findsOneWidget);",
          );
        }
      }

      print('\n$cyan$bold📋 GENERATED ASSERTIONS (Preview):$reset');
      print(buffer.toString());

      final save =
          (ask('\nSave assertions to test/ui_assertions.dart? (y/n)') ?? 'y')
              .toLowerCase() ==
          'y';

      if (save) {
        final saveFile = File(p.join(activePath, 'test', 'ui_assertions.dart'));
        if (!saveFile.parent.existsSync()) {
          saveFile.parent.createSync(recursive: true);
        }
        saveFile.writeAsStringSync(buffer.toString(), mode: FileMode.append);
        printSuccess('Assertions appended to test/ui_assertions.dart');
      }

      // Cleanup
      if (xmlFile.existsSync()) xmlFile.deleteSync();
    } catch (e) {
      printError('Visual Assertion capture failed: $e');
    }
  });

  ask('Press Enter to return');
}
