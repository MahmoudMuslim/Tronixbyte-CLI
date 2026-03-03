import 'package:tools/tools.dart';

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

void printStep(int current, int total, String message) {
  printProgressBar(
    current,
    total,
    prefix: '$bold[$current/$total]$reset $message',
  );
}
