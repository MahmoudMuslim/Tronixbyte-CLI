import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

// ANSI Color Codes
const String reset = '\x1B[0m';
const String bold = '\x1B[1m';
const String red = '\x1B[31m';
const String green = '\x1B[32m';
const String yellow = '\x1B[33m';
const String blue = '\x1B[34m';
const String cyan = '\x1B[36m';
const String magenta = '\x1B[35m';

/// Robustly clears the console and resets cursor position.
void clearConsole() {
  try {
    if (Platform.isWindows) {
      stdout.write('\x1B[2J\x1B[H');
    } else {
      stdout.write('\x1B[2J\x1B[3J\x1B[H');
    }
  } catch (_) {
    print('\n' * 100);
  }
}

void printSuccess(String message) => print('$green$bold✅ $message$reset');

void printError(String message) => print('$red$bold❌ $message$reset');

void printWarning(String message) => print('$yellow$bold⚠️ $message$reset');

void printInfo(String message) => print('$cyanℹ️ $message$reset');

void printSection(String title) {
  final line = '=' * 60;
  print('\n$blue$bold$line$reset');
  print(
    '$blue$bold ${title.toUpperCase().padLeft((60 + title.length) ~/ 2).padRight(60)} $reset',
  );
  print('$blue$bold$line$reset\n');
}

void printBanner() {
  print('$blue$bold');
  print(
    ' ████████╗██████╗  ██████╗ ███╗   ██╗██╗██╗  ██╗██████╗ ██╗   ██╗████████╗███████╗',
  );
  print(
    ' ╚══██╔══╝██╔══██╗██╔═══██╗████╗  ██║██║╚██╗██╔╝██╔══██╗╚██╗ ██╔╝╚══██╔══╝██╔════╝',
  );
  print(
    '    ██║   ██████╔╝██║   ██║██╔██╗ ██║██║ ╚███╔╝ ██████╔╝ ╚████╔╝    ██║   █████╗  ',
  );
  print(
    '    ██║   ██╔══██╗██║   ██║██║╚██╗██║██║ ██╔██╗ ██╔══██╗  ╚██╔╝     ██║   ██╔══╝  ',
  );
  print(
    '    ██║   ██║  ██║╚██████╔╝██║ ╚████║██║██╔╝ ██╗██████╔╝   ██║      ██║   ███████╗',
  );
  print(
    '    ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝╚═════╝    ╚═╝      ╚═╝   ╚══════╝',
  );
  print('                             ELITE FLUTTER TOOLKIT$reset');

  final lastCreated = InputHistoryManager.getRecentInputs('created_project');
  if (lastCreated.isNotEmpty) {
    print(
      '                             LAST PROJECT: $yellow${lastCreated.first}$reset',
    );
  }

  final activeProject = InputHistoryManager.getRecentInputs('active_project');
  if (activeProject.isNotEmpty) {
    print(
      '                             ACTIVE PROJECT: $green${activeProject.first}$reset',
    );
  }
  print('\n');
}

Future<T> loadingSpinner<T>(String message, Future<T> Function() task) async {
  const spinner = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
  int i = 0;
  bool loading = true;
  final stopwatch = Stopwatch()..start();

  Timer.periodic(const Duration(milliseconds: 80), (t) {
    if (!loading) {
      t.cancel();
      return;
    }
    stdout.write('\r$cyan${spinner[i % spinner.length]} $message...$reset');
    i++;
  });

  try {
    final result = await task();
    loading = false;
    stopwatch.stop();
    final elapsed = stopwatch.elapsedMilliseconds / 1000;

    // Log to historical tracker
    await PerformanceTracker.logCommand(message, elapsed);

    stdout.write(
      '\r$green$bold✅ $message (Done in ${elapsed.toStringAsFixed(1)}s)$reset\n',
    );
    return result;
  } catch (e) {
    loading = false;
    stdout.write('\r$red$bold❌ $message (Failed)$reset\n');
    rethrow;
  }
}

void printProgressBar(int current, int total, {String prefix = ''}) {
  const int barLength = 30;
  final double progress = (current / total).clamp(0.0, 1.0);
  final int filledLength = (barLength * progress).round();
  final String bar = '█' * filledLength + '░' * (barLength - filledLength);
  final String percent = (progress * 100).toStringAsFixed(0);

  stdout.write(
    '\r$prefix $cyan$bar$reset $bold$percent%$reset ($current/$total)',
  );
  if (current == total) stdout.write('\n');
}

void printTable(List<String> headers, List<List<String>> rows) {
  final colWidths = List<int>.filled(headers.length, 0);
  for (var i = 0; i < headers.length; i++) {
    colWidths[i] = headers[i].length;
    for (final row in rows) {
      if (row[i].length > colWidths[i]) colWidths[i] = row[i].length;
    }
  }

  String line = '+';
  for (final width in colWidths) {
    line += '${'-' * (width + 2)}+';
  }

  print(line);
  String headerRow = '|';
  for (var i = 0; i < headers.length; i++) {
    headerRow += ' $bold${headers[i].padRight(colWidths[i])}$reset |';
  }
  print(headerRow);
  print(line);

  for (final row in rows) {
    String rowStr = '|';
    for (var i = 0; i < row.length; i++) {
      rowStr += ' ${row[i].padRight(colWidths[i])} |';
    }
    print(rowStr);
  }
  print(line);
}

Future<void> ensureProjectRoot() async {
  // Check if we already have an active project set
  final activeProject = InputHistoryManager.getRecentInputs('active_project');
  if (activeProject.isNotEmpty) {
    final path = activeProject.first;
    if (Directory(path).existsSync() &&
        File(p.join(path, 'pubspec.yaml')).existsSync()) {
      Directory.current = path;
      return;
    }
  }

  if (!File('pubspec.yaml').existsSync()) {
    printWarning('No active project detected in the current directory.');

    final createdProjects = InputHistoryManager.getRecentInputs(
      'created_project',
    );
    if (createdProjects.isNotEmpty) {
      print(
        '\n$cyan${bold}Suggestions based on recently created projects:$reset',
      );
      for (var i = 0; i < createdProjects.length; i++) {
        print('  $cyan${i + 1}:$reset ${createdProjects[i]}');
      }
    }

    final path = ask('Please enter the Project absolute path');
    if (path != null && Directory(path).existsSync()) {
      Directory.current = path;
      if (!File('pubspec.yaml').existsSync()) {
        printError('pubspec.yaml still not found in $path. Exiting.');
        exit(1);
      }
      InputHistoryManager.saveInput(
        'active_project',
        Directory.current.absolute.path,
      );
      printSuccess('Project context set to: ${Directory.current.path}');
    } else {
      printError('Invalid directory or project not found. Exiting.');
      exit(1);
    }
  } else {
    // Current directory is a project, let's mark it as active
    InputHistoryManager.saveInput(
      'active_project',
      Directory.current.absolute.path,
    );
  }
}

Future<String> getProjectName() async {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    throw Exception('pubspec.yaml not found.');
  }
  final pubspecContent = pubspecFile.readAsStringSync();
  final nameMatch = RegExp(r'name:\s+([^\s\n\r]+)').firstMatch(pubspecContent);
  if (nameMatch == null) {
    throw Exception('Could not find project name in pubspec.yaml');
  }
  return nameMatch.group(1)!;
}

String? ask(String prompt) {
  final category = _identifyCategory(prompt);
  final recentInputs = InputHistoryManager.getRecentInputs(category);

  if (recentInputs.isNotEmpty) {
    print(
      '\n$cyan${bold}Recent ${category[0].toUpperCase()}${category.substring(1)}s:$reset',
    );
    for (var i = 0; i < recentInputs.length; i++) {
      print('  $cyan${i + 1}:$reset ${recentInputs[i]}');
    }
    print('');
  }

  stdout.write('   $magenta$bold❓ $prompt$reset: ');
  var input = stdin.readLineSync()?.trim();

  if (input != null && input.isNotEmpty) {
    final index = int.tryParse(input);
    if (index != null && index > 0 && index <= recentInputs.length) {
      input = recentInputs[index - 1];
      print('$green Selected: $input$reset');
    }
  }

  if (input != null && input.isNotEmpty) {
    InputHistoryManager.saveInput(category, input);
  }

  return (input?.isEmpty ?? true) ? null : input;
}

String _identifyCategory(String prompt) {
  final p = prompt.toLowerCase();
  if (p.contains('path') || p.contains('directory')) return 'path';
  if (p.contains('name')) return 'name';
  if (p.contains('endpoint') || p.contains('url')) return 'url';
  if (p.contains('package')) return 'package';
  if (p.contains('feature')) return 'feature';
  return 'general';
}

String? selectOption(
  String title,
  List<String> options, {
  bool showBack = true,
}) {
  clearConsole();
  printBanner();
  printSection(title);
  for (var i = 0; i < options.length; i++) {
    print(' $cyan${i + 1}:$reset ${options[i]}');
  }
  if (showBack) {
    print(' ${cyan}${options.length + 1}:$reset Back');
  }

  final maxChoice = showBack ? options.length + 1 : options.length;
  final choice = ask('Select an option (1-$maxChoice)');

  if (showBack && (choice == 'back' || choice == '$maxChoice')) return 'back';
  return choice;
}

void addField(StringBuffer sb, String key, String? value, [int indent = 0]) {
  if (value != null) sb.writeln('${'  ' * indent}$key: $value');
}

Future<void> runCommand(
  String command,
  List<String> args, {
  String? loadingMessage,
}) async {
  final stdoutData = <String>[];
  final stderrData = <String>[];

  if (loadingMessage != null) {
    try {
      await loadingSpinner(loadingMessage, () async {
        final result = await Process.run(command, args, runInShell: true);
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
    final process = await Process.start(command, args, runInShell: true);
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

void printStep(int current, int total, String message) {
  printProgressBar(
    current,
    total,
    prefix: '$bold[$current/$total]$reset $message',
  );
}

void updatePubspecAssets() {
  final file = File('pubspec.yaml');
  if (!file.existsSync()) return;
  String content = file.readAsStringSync();

  final folders = [
    'assets/translations/',
    'assets/images/',
    'assets/fonts/',
    'assets/svgs/',
  ];

  for (final folder in folders) {
    if (Directory(folder.replaceAll('/', '')).existsSync() &&
        !content.contains(folder)) {
      if (content.contains('  assets:')) {
        content = content.replaceFirst('  assets:', '  assets:\n    - $folder');
      } else if (content.contains('flutter:')) {
        content = content.replaceFirst(
          'flutter:',
          'flutter:\n  assets:\n    - $folder',
        );
      }
    }
  }

  if (File('.env').existsSync() && !content.contains('- .env')) {
    if (content.contains('  assets:')) {
      content = content.replaceFirst('  assets:', '  assets:\n    - .env');
    }
  }

  file.writeAsStringSync(content);
  printSuccess('Pubspec assets synchronized.');
}

void updateServiceBarrel(String fileName) {
  final barrelFile = File('lib/core/services/z_services.dart');
  final exportLine = "export '$fileName';\n";
  if (!barrelFile.existsSync()) {
    if (!barrelFile.parent.existsSync()) {
      barrelFile.parent.createSync(recursive: true);
    }
    barrelFile.writeAsStringSync(exportLine);
  } else {
    String content = barrelFile.readAsStringSync();
    if (!content.contains(fileName)) {
      barrelFile.writeAsStringSync('$content$exportLine');
    }
  }
}

Future<void> wireCoreInjection(String className) async {
  final injectionFile = File('lib/injection.dart');
  if (!injectionFile.existsSync()) return;
  String content = injectionFile.readAsStringSync();
  if (!content.contains(className)) {
    content = content.replaceFirst(
      '// --- Core ---',
      '// --- Core ---\n  sl.registerLazySingleton(() => $className());',
    );
    injectionFile.writeAsStringSync(content);
  }
}

final List<String> baseDeps = [
  'go_router',
  'get_it',
  'easy_localization',
  'intl',
  'equatable',
  'json_annotation',
  'equatable_annotations',
  'path_provider',
  'path',
  'package_info_plus',
  'device_info_plus',
  'wakelock_plus',
  'device_preview_plus',
  'iconify_flutter_plus',
  'colorful_iconify_flutter',
  'share_plus',
  'url_launcher',
  'flutter_svg',
  'feedback',
  'logger',
  'dartz',
  'flutter_dotenv',
];

final List<String> baseDevDeps = [
  'build_runner',
  'json_serializable',
  'equatable_gen',
  'go_router_builder',
  'flutter_native_splash',
  'package_rename',
  'icons_launcher',
  'mocktail',
];
final List<String> apiDeps = ['dio', 'retrofit', 'pretty_dio_logger'];
final List<String> apiDevDeps = ['retrofit_generator', 'build_runner'];
final List<String> databaseDeps = [
  'drift',
  'drift_flutter',
  'path_provider',
  'path',
];
final List<String> databaseDevDeps = ['drift_dev', 'build_runner'];

final Map<String, List<String>> stateManagementDeps = {
  'bloc': ['flutter_bloc', 'hydrated_bloc', 'replay_bloc', 'bloc_concurrency'],
  'cubit': ['flutter_bloc', 'hydrated_bloc', 'replay_bloc', 'bloc_concurrency'],
  'riverpod': ['hooks_riverpod', 'flutter_hooks', 'riverpod_annotation'],
  'getx': ['get_storage', 'get'],
  'provider': ['provider'],
};

final Map<String, List<String>> stateManagementDevDeps = {
  'bloc': ['bloc_test'],
  'cubit': ['bloc_test'],
  'riverpod': ['riverpod_generator'],
  'getx': [],
  'provider': [],
};

final List<String> firebaseBaseDeps = ['firebase_core'];
final Map<String, String> firebaseServices = {
  'firebase_core': 'Core Engine (Mandatory)',
  'firebase_auth': 'Identity & Auth',
  'firebase_ui_auth': 'FlutterFire UI for Auth',
  'cloud_firestore': 'NoSQL Cloud Database',
  'firebase_ui_firestore': 'FlutterFire UI for Firestore',
  'firebase_database': 'Realtime Database',
  'firebase_ui_database': 'FlutterFire UI for Realtime Database',
  'firebase_messaging': 'Push Notifications',
  'firebase_in_app_messaging': 'In-App Messaging',
  'firebase_storage': 'Cloud Asset Storage',
  'firebase_analytics': 'Behavioral Analytics',
  'firebase_crashlytics': 'Real-time Error Reporting',
  'firebase_performance': 'App Performance Monitoring',
  'firebase_remote_config': 'Dynamic App Configuration',
  'firebase_app_check': 'Security & Attestation',
};
