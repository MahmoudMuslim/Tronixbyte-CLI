import 'package:tools/tools.dart';

Future<void> runCommand(
  String command,
  List<String> args, {
  String? loadingMessage,
  String? workingDir,
}) async {
  final stdoutData = <String>[];
  final stderrData = <String>[];
  final finalDir = workingDir ?? getActiveProjectPath();

  if (loadingMessage != null) {
    try {
      await loadingSpinner(loadingMessage, () async {
        final result = await Process.run(
          command,
          args,
          runInShell: true,
          workingDirectory: finalDir,
        );
        if (result.exitCode != 0) {
          stdoutData.add(result.stdout.toString());
          stderrData.add(result.stderr.toString());
          throw Exception('Command failed');
        }
      });
    } catch (e) {
      if (stdoutData.isNotEmpty) print('\n$reset${stdoutData.join()}');
      if (stderrData.isNotEmpty) printError(stderrData.join());
      printError('Command failed with exit code 1');
    }
  } else {
    final stopwatch = Stopwatch()..start();
    final process = await Process.start(
      command,
      args,
      runInShell: true,
      workingDirectory: finalDir,
    );
    process.stdout.listen((data) => stdout.add(data));
    process.stderr.listen((data) => stderr.add(data));
    final exitCode = await process.exitCode;
    stopwatch.stop();
    final elapsed = stopwatch.elapsedMilliseconds / 1000;

    // Log to historical tracker
    await PerformanceTracker.logCommand('$command ${args.join(' ')}', elapsed);

    if (exitCode != 0) {
      printError('Command failed with exit code $exitCode');
    }
  }
}
