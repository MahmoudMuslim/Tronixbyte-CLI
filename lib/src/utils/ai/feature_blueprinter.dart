import 'package:tools/tools.dart';

Future<void> runFeatureBlueprinter(String description) async {
  printSection('🧠 AI Architect: Feature Blueprinting');

  final activePath = getActiveProjectPath();
  final projectName = await getProjectName();

  final typeChoice = selectOption('Select State Management for this Feature', [
    'BLoC (Business Logic Component)',
    'Cubit (Simplified BLoC)',
    'Riverpod (Reactive State Management)',
    'GetX (High-performance / Zero Boilerplate)',
    'Provider (Classic & Simple)',
  ], showBack: true);

  if (typeChoice == 'back' || typeChoice == null) return;

  String logicType = 'bloc';
  switch (typeChoice) {
    case '1':
      logicType = 'bloc';
      break;
    case '2':
      logicType = 'cubit';
      break;
    case '3':
      logicType = 'riverpod';
      break;
    case '4':
      logicType = 'getx';
      break;
    case '5':
      logicType = 'provider';
      break;
  }

  printInfo('Analyzing your intent: "$description"');
  printInfo('Targeting: $logicType architecture');
  printInfo('Consulting Gemini Pro 1.5 for architectural blueprint...');

  final apiKey = InputHistoryManager.getRecentInput('gemini_api_key');
  if (apiKey == null || apiKey.isEmpty) {
    printError('Gemini API Key not found in history.');
    printInfo(
      'Please run "AI Translation Wizard" first to set your API Key, or enter it now.',
    );
    final newKey = ask('Gemini API Key');
    if (newKey == null) return;
    InputHistoryManager.saveInput('gemini_api_key', newKey);
  }

  final finalApiKey =
      apiKey ?? InputHistoryManager.getRecentInput('gemini_api_key')!;

  try {
    final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: finalApiKey);

    final prompt = getAIFeatureBluePrinterTemplate(
      description,
      projectName,
      logicType,
    );

    Map<String, dynamic>? data;

    await loadingSpinner('Designing Clean Architecture layers', () async {
      final response = await model.generateContent([Content.text(prompt)]);
      final blueprintJson = response.text;

      if (blueprintJson != null) {
        final cleanJson = blueprintJson
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        data = json.decode(cleanJson);
      }
    });

    if (data == null) {
      printError('Failed to generate blueprint data.');
      return;
    }

    final featureName = data!['feature_name'] as String;
    final entityName = data!['entity_name'] as String;
    final fields = (data!['fields'] as List)
        .map((e) => Map<String, String>.from(e))
        .toList();
    final deps = List<String>.from(data!['dependencies'] ?? []);
    final methods = List<String>.from(data!['methods'] ?? []);
    final implementations = Map<String, String>.from(
      data!['implementations'] ?? {},
    );
    final summary = data!['summary'] as String;

    // Show Plan
    print('\n$blue$bold🚀 AI ARCHITECTURAL PLAN$reset');
    print('   $cyan Feature:$reset $featureName');
    print('   $cyan Entity:$reset  $entityName');
    print('   $cyan Logic:$reset   $logicType');
    print('   $cyan Summary:$reset $summary');

    print('\n$blue$bold📦 SUGGESTED DEPENDENCIES$reset');
    if (deps.isEmpty) {
      print('   None (Standard stack)');
    } else {
      for (var d in deps) {
        print('   - $d');
      }
    }

    print('\n$blue$bold🛠️  REPO INTERFACE$reset');
    for (var m in methods) {
      print('   - $m(...)');
    }

    final confirm =
        (ask('\nProceed with scaffolding this blueprint? (y/n)') ?? 'y')
            .toLowerCase() ==
        'y';
    if (!confirm) {
      printInfo('Blueprint discarded.');
      return;
    }

    // 1. Handle Dependencies
    if (deps.isNotEmpty) {
      final install =
          (ask('Install suggested dependencies via pub add? (y/n)') ?? 'y')
              .toLowerCase() ==
          'y';
      if (install) {
        await runCommand('flutter', [
          'pub',
          'add',
          ...deps,
        ], loadingMessage: 'Installing dependencies');
      }
    }

    // 2. Scaffold Feature
    await loadingSpinner(
      'Executing blueprint scaffolding in $activePath',
      () async {
        await generateFeature(
          featureName,
          logicType,
          fields: fields,
          needData: true,
          needDomain: true,
          needPresentation: true,
          needTests: true,
          customImplementations: implementations,
        );
      },
    );

    printSuccess(
      'AI Blueprinting complete! Feature "$featureName" has been scaffolded using $logicType.',
    );
    printInfo('👉 Run "tools sync" to wire injections and generate barrels.');
  } catch (e) {
    printError('Blueprinting failed: $e');
  }

  ask('Press Enter to return');
}
