import 'package:tools/tools.dart';

Future<void> dartBuildMenu() async {
  while (true) {
    final options = [
      'Build CLI Application (dart build cli)',
      'Compile to EXE (Self-contained executable)',
      'Compile to JS (JavaScript)',
      'Compile to WASM (WebAssembly)',
      'Compile to AOT Snapshot',
      'Compile to JIT Snapshot',
      'Compile to Kernel Snapshot',
    ];

    final choice = selectOption(
      'Dart Build & Compile Menu',
      options,
      showBack: true,
    );

    if (choice == 'back' || choice == null) return;

    if (choice == '1') {
      await runCommand('dart', [
        'build',
        'cli',
      ], loadingMessage: 'Building CLI application');
      printSuccess('CLI application built successfully.');
      continue;
    }

    final entryFile =
        ask('Entry file path (default: bin/main.dart or lib/main.dart)') ??
        (File('bin/main.dart').existsSync()
            ? 'bin/main.dart'
            : 'lib/main.dart');

    if (!File(entryFile).existsSync()) {
      printError('Entry file not found at $entryFile');
      continue;
    }

    String subcommand = '';
    String loadingMsg = '';
    switch (choice) {
      case '2':
        subcommand = 'exe';
        loadingMsg = 'Compiling to EXE';
        break;
      case '3':
        subcommand = 'js';
        loadingMsg = 'Compiling to JavaScript';
        break;
      case '4':
        subcommand = 'wasm';
        loadingMsg = 'Compiling to WASM';
        break;
      case '5':
        subcommand = 'aot-snapshot';
        loadingMsg = 'Generating AOT Snapshot';
        break;
      case '6':
        subcommand = 'jit-snapshot';
        loadingMsg = 'Generating JIT Snapshot';
        break;
      case '7':
        subcommand = 'kernel';
        loadingMsg = 'Generating Kernel Snapshot';
        break;
      default:
        printError('Invalid option.');
        continue;
    }

    final output = ask('Custom output path? (leave empty for default)');
    final List<String> compileArgs = ['compile', subcommand, entryFile];
    if (output != null && output.isNotEmpty) compileArgs.addAll(['-o', output]);

    final List<String> extraArgs = [];
    if (subcommand == 'js' || subcommand == 'wasm') {
      final opt = ask('Optimization level (0-4 - default: 4)');
      if (opt != null && opt.isNotEmpty) extraArgs.add('-O$opt');
    }

    await runCommand('dart', [
      ...compileArgs,
      ...extraArgs,
    ], loadingMessage: loadingMsg);
    printSuccess('$loadingMsg complete.');
  }
}
