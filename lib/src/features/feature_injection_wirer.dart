import 'package:tools/tools.dart';

Future<void> wireFeatureInjection(String namePascal) async {
  final injectionFile = File('lib/injection.dart');
  if (!injectionFile.existsSync()) {
    printWarning(
      'lib/injection.dart not found. Skipping automated injection wiring.',
    );
    return;
  }

  String content = injectionFile.readAsStringSync();
  final initCall = '  await init${namePascal}Injection();';

  if (!content.contains(initCall)) {
    content = content.replaceFirst(
      '// --- Features ---',
      '// --- Features ---\n$initCall',
    );
    injectionFile.writeAsStringSync(content);
    printSuccess('Wired init${namePascal}Injection() in lib/injection.dart');
  } else {
    printInfo('Injection for $namePascal already exists in lib/injection.dart');
  }
}
