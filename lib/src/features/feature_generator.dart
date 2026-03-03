import 'package:tools/tools.dart';

Future<void> generateFeature(
  String name,
  String type, {
  List<Map<String, String>>? fields,
  bool needData = false,
  bool needDomain = false,
  bool needPresentation = false,
  bool needRoute = false,
  bool needTests = false,
  bool overwrite = false,
}) async {
  final projectName = await getProjectName();
  final namePascal = name[0].toUpperCase() + name.substring(1);
  final featurePath = 'lib/features/$name';

  String logicDir;
  String logicClass;
  String logicTemplate;
  String stateTemplate;
  String eventTemplate = '';

  switch (type) {
    case 'bloc':
      logicDir = 'bloc';
      logicClass = '${namePascal}Bloc';
      logicTemplate = getBlocTemplate(projectName, name, namePascal);
      stateTemplate = getStateTemplate(name, namePascal);
      eventTemplate = getEventTemplate(name, namePascal);
      break;
    case 'cubit':
      logicDir = 'cubit';
      logicClass = '${namePascal}Cubit';
      logicTemplate = getCubitTemplate(projectName, name, namePascal);
      stateTemplate = getCubitStateTemplate(name, namePascal);
      break;
    case 'riverpod':
      logicDir = 'provider';
      logicClass = '${namePascal}Notifier';
      logicTemplate = getRiverpodTemplate(projectName, name, namePascal);
      stateTemplate = getRiverpodStateTemplate(name, namePascal);
      break;
    case 'getx':
      logicDir = 'controller';
      logicClass = '${namePascal}Controller';
      logicTemplate = getGetXTemplate(projectName, name, namePascal);
      stateTemplate = getGetXStateTemplate(name, namePascal);
      break;
    case 'provider':
      logicDir = 'provider';
      logicClass = '${namePascal}Provider';
      logicTemplate = getProviderTemplate(projectName, name, namePascal);
      stateTemplate = getProviderStateTemplate(name, namePascal);
      break;
    default:
      logicDir = 'cubit';
      logicClass = '${namePascal}Cubit';
      logicTemplate = getCubitTemplate(projectName, name, namePascal);
      stateTemplate = getCubitStateTemplate(name, namePascal);
  }

  printSection('Initializing feature: $name with $type');

  if (!Directory(featurePath).existsSync()) {
    Directory(featurePath).createSync(recursive: true);
    printInfo('Created directory: $featurePath');
  }

  final dirs = <String>[
    '$featurePath/manager',
    if (needData) ...[
      '$featurePath/data/datasources',
      '$featurePath/data/models',
      '$featurePath/data/repositories',
    ],
    if (needDomain) ...[
      '$featurePath/domain/entities',
      '$featurePath/domain/usecases',
      '$featurePath/domain/repositories',
    ],
    if (needPresentation) ...[
      '$featurePath/presentation/screens',
      '$featurePath/presentation/widgets',
    ],
  ];

  for (final dir in dirs) {
    if (!Directory(dir).existsSync()) {
      Directory(dir).createSync(recursive: true);
      printInfo('Created directory: $dir');
    }
  }

  printInfo('Generating files and barrel exports...');
  final files = <String, String>{
    // Logic
    '$featurePath/manager/${name}_${logicDir == 'controller' ? 'controller' : (logicDir == 'provider' ? 'provider' : (logicDir == 'bloc' ? 'bloc' : 'cubit'))}.dart':
        logicTemplate,
    if (type == 'bloc')
      '$featurePath/manager/${name}_event.dart': eventTemplate,
    '$featurePath/manager/${name}_state.dart': stateTemplate,
    '$featurePath/manager/z_$logicDir.dart':
        "export '${name}_${logicDir == 'controller' ? 'controller' : (logicDir == 'provider' ? 'provider' : (logicDir == 'bloc' ? 'bloc' : 'cubit'))}.dart';",

    // Data layer
    if (needData) ...{
      '$featurePath/data/datasources/${name}_datasource.dart':
          getDataSourceTemplate(projectName, namePascal),
      '$featurePath/data/datasources/z_datasources.dart':
          "export '${name}_datasource.dart';",
      '$featurePath/data/models/${name}_model.dart': getModelTemplate(
        projectName,
        name,
        namePascal,
        fields,
      ),
      if (needDomain)
        '$featurePath/data/models/${name}_mapper.dart': getMapperTemplate(
          projectName,
          namePascal,
          fields,
        ),
      '$featurePath/data/models/z_models.dart': needDomain
          ? "export '${name}_model.dart';\nexport '${name}_mapper.dart';"
          : "export '${name}_model.dart';",
      '$featurePath/data/repositories/${name}_repository_impl.dart':
          getRepositoryImplTemplate(projectName, namePascal),
      '$featurePath/data/repositories/z_repositories.dart':
          "export '${name}_repository_impl.dart';",
      '$featurePath/data/z_data.dart':
          "export 'datasources/z_datasources.dart';\nexport 'models/z_models.dart';\nexport 'repositories/z_repositories.dart';",
    },

    // Domain layer
    if (needDomain) ...{
      '$featurePath/domain/entities/${name}_entity.dart': getEntityTemplate(
        projectName,
        name,
        namePascal,
        fields,
      ),
      '$featurePath/domain/entities/z_entities.dart':
          "export '${name}_entity.dart';",
      '$featurePath/domain/usecases/${name}_usecase.dart': getUseCaseTemplate(
        projectName,
        namePascal,
      ),
      '$featurePath/domain/usecases/z_usecases.dart':
          "export '${name}_usecase.dart';",
      '$featurePath/domain/repositories/${name}_repository.dart':
          getRepositoryTemplate(projectName, namePascal),
      '$featurePath/domain/repositories/z_repositories.dart':
          "export '${name}_repository.dart';",
      '$featurePath/domain/z_domain.dart':
          "export 'entities/z_entities.dart';\nexport 'usecases/z_usecases.dart';\nexport 'repositories/z_repositories.dart';",
    },

    // Presentation Layer
    if (needPresentation) ...{
      '$featurePath/presentation/screens/${name}_screen.dart':
          getScreenTemplate(projectName, namePascal, logicClass, type),
      '$featurePath/presentation/screens/z_screens.dart':
          "export '${name}_screen.dart';",
      '$featurePath/presentation/widgets/${name}_body.dart': getBodyTemplate(
        projectName,
        name,
        namePascal,
        logicClass,
        type,
      ),
      '$featurePath/presentation/widgets/z_widgets.dart':
          "export '${name}_body.dart';",
      '$featurePath/presentation/z_presentation.dart':
          "export 'screens/z_screens.dart';\nexport 'widgets/z_widgets.dart';",
    },

    // Injection
    '$featurePath/${name}_injection.dart': getFeatureInjectionTemplate(
      projectName,
      namePascal,
      logicClass,
      needDomain,
      needData,
      type,
    ),

    // Feature Barrel
    '$featurePath/z_$name.dart': [
      "export '${name}_injection.dart';",
      "export 'manager/z_$logicDir.dart';",
      if (needData) "export 'data/z_data.dart';",
      if (needDomain) "export 'domain/z_domain.dart';",
      if (needPresentation) "export 'presentation/z_presentation.dart';",
    ].join('\n'),
  };

  files.forEach((path, content) {
    final file = File(path);
    if (file.existsSync() && !overwrite) return;
    file.writeAsStringSync(content);
    printSuccess('Generated: $path');
  });

  if (needRoute && needPresentation) {
    await generateFeatureRoute(name, projectName, namePascal);
  }

  if (needTests) {
    await _generateFeatureTests(
      name,
      projectName,
      namePascal,
      type,
      needPresentation,
    );
  }

  // Automated Injection Wiring
  await wireFeatureInjection(namePascal);

  // Update Features Barrel
  await _updateFeaturesBarrel(name);

  printSuccess('Feature $name created and wired successfully!');
}

Future<void> _updateFeaturesBarrel(String name) async {
  final barrelFile = File('lib/features/z_features.dart');
  final exportLine = "export '$name/z_$name.dart';";

  if (!barrelFile.existsSync()) {
    barrelFile.writeAsStringSync('$exportLine\n', mode: FileMode.append);
  } else {
    String content = barrelFile.readAsStringSync();
    if (!content.contains(exportLine)) {
      barrelFile.writeAsStringSync(
        '$content$exportLine\n',
        mode: FileMode.append,
      );
    }
  }
}

Future<void> _generateFeatureTests(
  String name,
  String projectName,
  String namePascal,
  String type,
  bool needPresentation,
) async {
  final testPath = 'test/features/$name';
  if (!Directory(testPath).existsSync()) {
    Directory(testPath).createSync(recursive: true);
  }

  String logicTestContent;
  switch (type) {
    case 'bloc':
      logicTestContent = getBlocTestTemplate(projectName, namePascal);
      break;
    case 'cubit':
      logicTestContent = getCubitTestTemplate(projectName, namePascal);
      break;
    case 'riverpod':
      logicTestContent = getRiverpodTestTemplate(projectName, name, namePascal);
      break;
    case 'getx':
      logicTestContent = getGetXTestTemplate(projectName, namePascal);
      break;
    case 'provider':
      logicTestContent = getProviderTestTemplate(projectName, namePascal);
      break;
    default:
      logicTestContent = getCubitTestTemplate(projectName, namePascal);
  }

  final testFile = File('$testPath/${name}_${type}_test.dart');
  if (!testFile.existsSync()) {
    testFile.writeAsStringSync(logicTestContent, mode: FileMode.append);
    printSuccess('Generated: $testPath/${name}_${type}_test.dart');
  }

  if (needPresentation) {
    final widgetTestFile = File('$testPath/${name}_screen_test.dart');
    if (!widgetTestFile.existsSync()) {
      widgetTestFile.writeAsStringSync(
        getWidgetTestTemplate(projectName, namePascal),
        mode: FileMode.append,
      );
      printSuccess('Generated: $testPath/${name}_screen_test.dart');
    }
  }
}
