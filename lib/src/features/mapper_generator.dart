import 'package:tools/tools.dart';

Future<void> generateSmartMapper() async {
  printSection('Smart Model-to-Entity Mapper Generator');

  final featureName = ask('Enter the feature name (e.g., auth)');
  if (featureName == null) return;

  final entityPath =
      'lib/features/$featureName/domain/entities/${featureName}_entity.dart';
  final modelPath =
      'lib/features/$featureName/data/models/${featureName}_model.dart';
  final mapperPath =
      'lib/features/$featureName/data/models/${featureName}_mapper.dart';

  final entityFile = File(entityPath);
  final modelFile = File(modelPath);

  if (!entityFile.existsSync() || !modelFile.existsSync()) {
    printError('Could not find Entity or Model for feature: $featureName');
    return;
  }

  await loadingSpinner('Parsing Entity and generating mapper', () async {
    final entityContent = entityFile.readAsStringSync();

    // Extract fields: matches "final Type name;"
    final fieldRegex = RegExp(r'final\s+([\w<>,? ]+)\s+(\w+);');
    final matches = fieldRegex.allMatches(entityContent);

    if (matches.isEmpty) {
      printWarning('No fields found in Entity. Is it empty?');
      return;
    }

    final fields = matches
        .map((m) => {'type': m.group(1)!, 'name': m.group(2)!})
        .toList();
    final namePascal = featureName[0].toUpperCase() + featureName.substring(1);
    final projectName = await getProjectName();

    // Use the template from mapper_templates.dart
    final mapperTemplate = getMapperTemplate(projectName, namePascal, fields);

    File(mapperPath).writeAsStringSync(mapperTemplate);

    // Update Data Barrel
    _updateDataBarrel(featureName);

    printInfo('Mappings for: ${fields.map((f) => f['name']).join(', ')}');
  });

  printSuccess('Mapper generated successfully: $mapperPath');
}

void _updateDataBarrel(String feature) {
  final barrelFile = File('lib/features/$feature/data/models/z_models.dart');
  final exportLine = "export '${feature}_mapper.dart';\n";

  if (barrelFile.existsSync()) {
    String content = barrelFile.readAsStringSync();
    if (!content.contains('${feature}_mapper.dart')) {
      barrelFile.writeAsStringSync('$content$exportLine');
    }
  } else {
    barrelFile.writeAsStringSync(exportLine);
  }
}
