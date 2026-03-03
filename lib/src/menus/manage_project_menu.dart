import 'package:tools/tools.dart';

Future<void> manageProjectMenu() async {
  await ensureProjectRoot();

  while (true) {
    final activePath = getActiveProjectPath();
    final options = [
      'Show Elite Project Dashboard (Real-time)',
      'Run Full Project Setup (All-in-one Initialization)',
      'Feature Management (Create/Delete/Rename/Enhance)',
      'Elite Module Marketplace (Plug-and-Play)',
      'Enterprise Whitelabeling Wizard',
      'Figma Design System Sync',
      'Dynamic Widget Catalog (Gallery)',
      'Elite Monorepo Manager (Multi-Package)',
      'Interactive Git Flow Manager',
      'App Screenshot Automator (Multi-Device)',
      'Core Services Management (Logger, Network, Storage)',
      'Sync Project (Pub get, Build Runner, L10n)',
      'Project Configuration Hub (Individual Modules)',
      'Manage Dependencies & Global Exports',
      'Build Runner Tools',
      'Assets & Localization',
      'Build & Release Hub',
      'Switch Environment (Dev/Stg/Prod)',
      'Environment Secret Wizard (Sync Keys)',
      'Generate Features Overview (Health Status)',
      'Project Velocity Predictor (Release Trends)',
      'Manage App Version',
      'Project Health & Maintenance',
      'Change/Switch Managed Project',
    ];

    final choice = selectOption(
      'Tronixbyte Project Management',
      options,
      showBack: true,
    );

    switch (choice) {
      case '1':
        await showProjectDashboard();
        break;
      case '2':
        await runFullSetup();
        break;
      case '3':
        await featureManagementMenu();
        break;
      case '4':
        await runMarketplaceWizard();
        break;
      case '5':
        await runWhitelabelWizard();
        break;
      case '6':
        await runFigmaSync();
        break;
      case '7':
        await runSharedComponentGallery();
        break;
      case '8':
        await runMonorepoManager();
        break;
      case '9':
        await runGitFlowManager();
        break;
      case '10':
        await setupScreenshotAutomation();
        break;
      case '11':
        await coreServicesMenu();
        break;
      case '12':
        await syncProject();
        break;
      case '13':
        await runConfigGeneratorMenu();
        break;
      case '14':
        await manageDependencies();
        break;
      case '15':
        await buildRunnerMenu();
        break;
      case '16':
        await assetsAndL10nMenu();
        break;
      case '17':
        await buildAndReleaseMenu();
        break;
      case '18':
        await switchEnvironment();
        break;
      case '19':
        await runEnvSecretWizard();
        break;
      case '20':
        await generateFeaturesOverview();
        break;
      case '21':
        await runVelocityPredictor();
        break;
      case '22':
        await manageVersion();
        break;
      case '23':
        await maintenanceMenu();
        break;
      case '24':
        // Clear active project and re-run selection
        await InputHistoryManager.removeInput('active_project', activePath);
        await ensureProjectRoot();
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
