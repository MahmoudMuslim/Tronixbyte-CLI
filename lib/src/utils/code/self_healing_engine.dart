import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runSelfHealingEngine() async {
  printSection('🛠️ Self-Healing Code Engine (AI-Powered)');

  final activePath = getActiveProjectPath();
  printInfo('Scanning for lint warnings and errors in $activePath...');

  final apiKey = InputHistoryManager.getRecentInput('gemini_api_key');
  if (apiKey == null || apiKey.isEmpty) {
    printError('Gemini API Key required for self-healing.');
    return;
  }

  List<String> issues = [];
  await loadingSpinner('Analyzing codebase', () async {
    final result = await Process.run('flutter', [
      'analyze',
    ], workingDirectory: activePath);
    if (result.exitCode == 0) {
      printSuccess('No issues found! Your code is clean.');
      return;
    }
    issues = result.stdout
        .toString()
        .split('\n')
        .where(
          (l) =>
              l.startsWith(' info') ||
              l.startsWith(' warning') ||
              l.startsWith(' error'),
        )
        .toList();
  });

  if (issues.isEmpty) return;

  printWarning(
    'Found ${issues.length} issues. Starting AI self-healing process...',
  );

  for (var issue in issues.take(5)) {
    // Limit to 5 for now to avoid token overload
    print('\n$cyan⚡ Fixing Issue:$reset $issue');

    // Parse issue: " info • The value of the local variable 'activePath' isn't used • lib/src/utils/code/visual_assertion_generator.dart:6:9 • (unused_local_variable)"
    final parts = issue.split(' • ');
    if (parts.length < 3) continue;

    final message = parts[1];
    final location = parts[2];
    final errorCode = parts.last;

    final locParts = location.split(':');
    final filePath = locParts[0];
    final line = int.parse(locParts[1]);

    final file = File(p.join(activePath, filePath));
    if (!file.existsSync()) continue;

    final content = file.readAsStringSync();

    await loadingSpinner('Gemini is synthesizing a fix', () async {
      try {
        final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);

        final prompt =
            """
        You are an expert Flutter Developer. Fix the following lint/error in the provided code.
        
        ISSUE: $message ($errorCode)
        FILE: $filePath
        LINE: $line
        
        CODE:
        $content
        
        Provide ONLY the full corrected Dart code for the entire file. No explanations.
        """;

        final response = await model.generateContent([Content.text(prompt)]);
        final fixedCode = response.text
            ?.replaceAll('```dart', '')
            .replaceAll('```', '')
            .trim();

        if (fixedCode != null && fixedCode.isNotEmpty) {
          file.writeAsStringSync(fixedCode);
          printSuccess('Issue fixed in $filePath');
        }
      } catch (e) {
        printError('Failed to fix issue: $e');
      }
    });
  }

  printSuccess('Self-healing cycle complete.');
  ask('Press Enter to return');
}
