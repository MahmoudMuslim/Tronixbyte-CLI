import 'package:tools/tools.dart';

Future<void> addLocalizationKey() async {
  printSection('Localization Key Wizard');

  final key = ask('Enter the new localization key (e.g., login_error)');
  if (key == null || key.isEmpty) return;

  final enValue = ask('Enter the English translation');
  final arValue = ask('Enter the Arabic translation');

  if (enValue == null || arValue == null) {
    printError('Both translations are required.');
    return;
  }

  await loadingSpinner('Updating translation files', () async {
    await _updateJson('assets/translations/en.json', key, enValue);
    await _updateJson('assets/translations/ar.json', key, arValue);
  });

  printSuccess('Key "$key" added to both en.json and ar.json.');

  final runGen =
      (ask('Run localization generator now? (y/n)') ?? 'y').toLowerCase() ==
      'y';
  if (runGen) {
    await runCommand('dart', [
      'run',
      'easy_localization:generate',
      '-S',
      'assets/translations',
      '-f',
      'keys',
      '-o',
      'locale_keys.g.dart',
      '-O',
      'lib/l10n',
    ], loadingMessage: 'Generating localization keys');
    printSuccess('Keys generated successfully.');
  }
}

Future<void> _updateJson(String path, String key, String value) async {
  final file = File(path);
  if (!file.existsSync()) {
    if (!file.parent.existsSync()) file.parent.createSync(recursive: true);
    file.writeAsStringSync('{}');
  }

  final Map<String, dynamic> content = json.decode(file.readAsStringSync());
  content[key] = value;

  final encoder = const JsonEncoder.withIndent('  ');
  file.writeAsStringSync(encoder.convert(content));
}
