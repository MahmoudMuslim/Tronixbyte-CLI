import 'package:tools/tools.dart';

String? ask(String prompt, {bool useHistory = true}) {
  final category = _identifyCategory(prompt);
  final recentInputs = useHistory
      ? InputHistoryManager.getRecentInputs(category)
      : <String>[];

  if (useHistory && recentInputs.isNotEmpty) {
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

  if (useHistory && input != null && input.isNotEmpty) {
    final index = int.tryParse(input);
    if (index != null && index > 0 && index <= recentInputs.length) {
      input = recentInputs[index - 1];
      print('$green Selected: $input$reset');
    }
  }

  // Only save if history is enabled for this prompt
  if (useHistory && input != null && input.isNotEmpty) {
    InputHistoryManager.saveInput(category, input);
  }

  return (input?.isEmpty ?? true) ? null : input;
}

String _identifyCategory(String prompt) {
  final p = prompt.toLowerCase();
  if (p.contains('path') || p.contains('directory')) return 'path';
  if (p.contains('name')) return 'name';
  if (p.contains('endpoint') || p.contains('url') || p.contains('href')) {
    return 'url';
  }
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
    print(' $cyan${options.length + 1}:$reset Back');
  }

  final maxChoice = showBack ? options.length + 1 : options.length;
  // Menu selection should NOT use/pollute history
  final choice = ask('Select an option (1-$maxChoice)', useHistory: false);

  if (showBack && (choice == 'back' || choice == '$maxChoice')) return 'back';
  return choice;
}

void addField(StringBuffer sb, String key, String? value, [int indent = 0]) {
  if (value != null) sb.writeln('${'  ' * indent}$key: $value');
}
