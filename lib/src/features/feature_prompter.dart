import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> promptGenerateFeature() async {
  printSection('New Feature Wizard');

  final activePath = getActiveProjectPath();
  final name = ask('Feature Name (e.g., auth)');
  if (name == null || name.isEmpty) return;

  // Check if feature already exists
  final featurePath = p.join(activePath, 'lib', 'features', name);
  bool overwrite = false;
  if (Directory(featurePath).existsSync()) {
    printWarning('Feature "$name" already exists at $featurePath');
    overwrite =
        (ask('Overwrite existing files? (y/n)') ?? 'n').toLowerCase() == 'y';
    if (!overwrite) return;
  }

  final options = ['BLoC', 'Cubit', 'Riverpod', 'GetX', 'Provider'];
  final typeChoice = selectOption(
    'Select State Management Type',
    options,
    showBack: false,
  );

  String type;
  switch (typeChoice) {
    case '1':
      type = 'bloc';
      break;
    case '2':
      type = 'cubit';
      break;
    case '3':
      type = 'riverpod';
      break;
    case '4':
      type = 'getx';
      break;
    case '5':
      type = 'provider';
      break;
    default:
      printWarning('Invalid choice. Defaulting to Cubit.');
      type = 'cubit';
  }

  // Define Fields
  printSection('Field Definition (Optional)');
  printInfo('Format: type name (e.g., String id, int age)');
  printInfo('Leave empty and press Enter when done.');

  final fields = <Map<String, String>>[];
  while (true) {
    final input = ask('Field (type name)');
    if (input == null || input.isEmpty) break;

    final parts = input.split(' ');
    if (parts.length >= 2) {
      fields.add({'type': parts[0], 'name': parts[1]});
      printSuccess('Added field: ${parts[0]} ${parts[1]}');
    } else {
      printWarning('Invalid format. Use: type name');
    }
  }

  printSection('Layer Configuration');
  final needData = (ask('Need Data Layer? (y/n)') ?? 'n').toLowerCase() == 'y';
  final needDomain =
      (ask('Need Domain Layer? (y/n)') ?? 'n').toLowerCase() == 'y';
  final needPresentation =
      (ask('Need Presentation Layer? (y/n)') ?? 'n').toLowerCase() == 'y';

  bool needRoute = false;
  if (needPresentation) {
    needRoute = (ask('Need Route? (y/n)') ?? 'n').toLowerCase() == 'y';
  }

  final needTests =
      (ask('Generate Unit & Widget Tests? (y/n)') ?? 'n').toLowerCase() == 'y';

  await generateFeature(
    name,
    type,
    fields: fields,
    needData: needData,
    needDomain: needDomain,
    needPresentation: needPresentation,
    needRoute: needRoute,
    needTests: needTests,
    overwrite: overwrite,
  );
}
