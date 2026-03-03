import 'package:tools/tools.dart';

Future<void> featureManagementMenu() async {
  while (true) {
    final options = [
      'Generate a New Feature (Manual Scaffolding)',
      '🧠 AI Architect: Feature Blueprinting (Gemini)',
      'Enhance an existing feature (Add Layers)',
      'Generate Model-to-Entity Mappers',
      'Generate Automated Mocks (for Tests)',
      'Generate Advanced Test Suite (Widget/Goldens/Integration)',
      '🧪 Golden Test Designer (Visual Scaffolding)',
      '🧪 "Ghost" Integration Test Recorder (Mock)',
      '🧪 Visual Assertion Generator (State Scaffolding)',
      '🧪 Cross-Device Playback Matrix (QA Suite)',
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
        final desc = ask(
          'Enter a description for the feature (e.g., "A task manager with local storage")',
        );
        if (desc != null && desc.isNotEmpty) {
          await runFeatureBlueprinter(desc);
        }
        break;
      case '3':
        await promptAddFeatureLayer();
        break;
      case '4':
        await generateSmartMapper();
        break;
      case '5':
        await generateMocks();
        break;
      case '6':
        await runTestSuiteGenerator();
        break;
      case '7':
        await runGoldenDesigner();
        break;
      case '8':
        await runIntegrationTestRecorder();
        break;
      case '9':
        await runVisualAssertionGenerator();
        break;
      case '10':
        await runPlaybackMatrix();
        break;
      case '11':
        await runFeatureCoverageAudit();
        break;
      case '12':
        await runWidgetCoverageHeatmap();
        break;
      case '13':
        await runAnalyticsAudit();
        break;
      case '14':
        await generateSharedUiBoilerplate();
        break;
      case '15':
        await generateSharedWidget();
        break;
      case '16':
        await generateApiEndpoint();
        break;
      case '17':
        await promptRenameFeature();
        break;
      case '18':
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
