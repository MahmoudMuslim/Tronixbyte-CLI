import 'package:tools/tools.dart';

Future<void> featureManagementMenu() async {
  while (true) {
    final options = [
      'Generate a New Feature',
      'Enhance an existing feature (Add Layers)',
      'Generate Model-to-Entity Mappers',
      'Generate Automated Mocks (for Tests)',
      'Generate Advanced Test Suite (Widget/Goldens/Integration)',
      '🧪 Golden Test Designer (Visual Scaffolding)',
      '📊 Feature-Level Code Coverage Mapper',
      '🔥 Widget Coverage Heatmap (UI Testing Depth)',
      '🧪 Behavioral Analytics Auditor (Event Mapping)',
      'Generate Shared UI Boilerplate Widgets (AppButton, etc.)',
      'Generate a Shared Widget',
      'Generate an API Endpoint',
      'Rename a Feature',
      'DELETE an Existing Feature',
    ];

    final choice = selectOption('Feature Management', options, showBack: true);

    switch (choice) {
      case '1':
        await promptGenerateFeature();
        break;
      case '2':
        await promptAddFeatureLayer();
        break;
      case '3':
        await generateSmartMapper();
        break;
      case '4':
        await generateMocks();
        break;
      case '5':
        await runTestSuiteGenerator();
        break;
      case '6':
        await runGoldenDesigner();
        break;
      case '7':
        await runFeatureCoverageAudit();
        break;
      case '8':
        await runWidgetCoverageHeatmap();
        break;
      case '9':
        await runAnalyticsAudit();
        break;
      case '10':
        await generateSharedUiBoilerplate();
        break;
      case '11':
        await generateSharedWidget();
        break;
      case '12':
        await generateApiEndpoint();
        break;
      case '13':
        await promptRenameFeature();
        break;
      case '14':
        await promptRemoveFeature();
        break;
      case 'back':
        return;
      case null:
        break;
      default:
        printError('Invalid option.');
    }
  }
}
