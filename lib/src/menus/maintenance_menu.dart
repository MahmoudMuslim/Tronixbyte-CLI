import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> maintenanceMenu() async {
  while (true) {
    final options = [
      'Project Doctor (Deep Diagnosis)',
      'Project Repair (Nuclear Sync & Fix)',
      'Code Quality Suite (Format, Fix, Analyze, Test)',
      'Security & Secret Audit',
      'Performance & Size Audit',
      'Production Readiness Audit',
      'Package Publisher Assistant (Readiness Check)',
      'Advanced Obfuscation Wizard (IP Protection)',
      'Performance Analytics Dashboard (CLI Speed)',
      'Feature Complexity Auditor (LOC, Logic, Widgets)',
      'Detailed Code Metrics (LOC, logic/ui ratio)',
      'Memory Leak & AST Resource Auditor',
      'Dead Code & Asset Purger (Nuclear Clean)',
      'Self-Healing Code Engine (AI Lint Fixer)',
      'Find & Clean Unused Assets',
      'Find & Remove Unused Dependencies',
      'Dependency & Architecture Linter (Cycles, Layers)',
      'Live Security Vulnerability Feed (OSV.dev)',
      'License Compliance & GPL Guard',
      'Naming Convention Enforcer (lib/ snake_case)',
      'Fix Relative Imports (Convert to package: imports)',
      'Project Statistics & Overview',
      'Refresh All Barrel Files (z_*.dart)',
      'Generate VS Code Snippets & Task Integrations',
      'Generate Professional README.md',
      'Generate Feature-Level Documentation (READMEs)',
      'Generate App Changelog (History)',
      'Generate VS Code Debug Configs (launch.json)',
      'Install Git Pre-commit Hooks',
      'Configure GitHub CI/CD Workflows',
      'Deep Clean (Purge generated files & build artifacts)',
      'Flutter Clean & Get',
      'API Stress Tester (Elite Load)',
      'API Penetration Tester (Mock Security Attacks)',
      'API Regression Tester (Status & Schema Check)',
      'UI Screenshot Comparison (Pixel Match)',
      'Golden Test Manager (Approve/Reject Visuals)',
      'API Documentation Auditor (/// Verification)',
      'Automated Store Metadata Scraper (Fastlane Sync)',
      'Dependency License Auditor (OSS Compliance)',
      'Project Architectural Map (Graphviz Visualizer)',
      'Design System Auditor (UI Consistency)',
      'Design System Studio (Material 3 Token Generator)',
      'Dynamic Flavor Code-Gen (main_*.dart)',
      'Logic Flow Obfuscation Guard (Research)',
      'Secure Enclave Bridge (Biometric Storage)',
      'SSL Pinning Security Wizard',
      'Root & Jailbreak Detection Wizard',
      'Advanced Biometric Auth Scaffolder',
      'Project Growth Forecaster (Trend Analytics)',
      'Device-Specific Performance Auditor (FPS Simulation)',
      'Advanced API Mock Server (Local Scaffolding)',
      'Visual Technical Debt Monitor (Health Score)',
    ];

    final choice = selectOption(
      'Project Health & Maintenance',
      options,
      showBack: true,
    );

    switch (choice) {
      case '1':
        await runProjectDoctor();
        break;
      case '2':
        await repairProject();
        break;
      case '3':
        await runCodeQualityTools();
        break;
      case '4':
        await runSecurityAudit();
        break;
      case '5':
        await runPerformanceAudit();
        break;
      case '6':
        await runProductionAudit();
        break;
      case '7':
        await runPublisherAssistant();
        break;
      case '8':
        await runObfuscationWizard();
        break;
      case '9':
        await showPerformanceDashboard();
        break;
      case '10':
        await runFeatureComplexityAudit();
        break;
      case '11':
        await runCodeMetrics();
        break;
      case '12':
        await runMemoryLeakAudit();
        break;
      case '13':
        await runDeadCodePurge();
        break;
      case '14':
        await runSelfHealingEngine();
        break;
      case '15':
        await findUnusedAssets();
        break;
      case '16':
        await findUnusedDependencies();
        break;
      case '17':
        await checkDependencies();
        await checkArchitecture();
        await enforceArchitecturalBoundaries();
        await detectCircularDependencies();
        break;
      case '18':
        await runLiveSecurityFeed();
        break;
      case '19':
        await runLicenseComplianceGuard();
        break;
      case '20':
        await enforceNamingConventions();
        break;
      case '21':
        await fixRelativeImports();
        break;
      case '22':
        await showProjectStats();
        break;
      case '23':
        await refreshBarrels();
        break;
      case '24':
        await generateVsCodeSnippets();
        await generateVsCodeTasks();
        break;
      case '25':
        await generateReadme();
        break;
      case '26':
        await generateFeatureDocumentation();
        break;
      case '27':
        await generateChangelog();
        break;
      case '28':
        await generateDebugConfigs();
        break;
      case '29':
        await installGitHooks();
        break;
      case '30':
        await configureCiCd();
        break;
      case '31':
        await _runDeepClean();
        break;
      case '32':
        await runCommand('flutter', ['clean']);
        await runCommand('flutter', ['pub', 'get']);
        break;
      case '33':
        await runApiStressTester();
        break;
      case '34':
        await runPenetrationTest();
        break;
      case '35':
        await runApiRegressionTester();
        break;
      case '36':
        await runScreenshotComparison();
        break;
      case '37':
        await runGoldenManager();
        break;
      case '38':
        await runApiDocAudit();
        break;
      case '39':
        await runStoreMetadataAudit();
        break;
      case '40':
        await runLicenseAudit();
        break;
      case '41':
        await runArchitectureMapping();
        break;
      case '42':
        await runDesignSystemAudit();
        break;
      case '43':
        await runDesignSystemStudio();
        break;
      case '44':
        await runFlavorGenerator();
        break;
      case '45':
        await runObfuscationGuard();
        break;
      case '46':
        await runSecureEnclaveBridge();
        break;
      case '47':
        await runSslPinningWizard();
        break;
      case '48':
        await runJailbreakDetectionWizard();
        break;
      case '49':
        await runBiometricAuthWizard();
        break;
      case '50':
        await runGrowthForecaster();
        break;
      case '51':
        await runDevicePerformanceAudit();
        break;
      case '52':
        await runApiMockServerGenerator();
        break;
      case '53':
        await runTechDebtMonitor();
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

Future<void> _runDeepClean() async {
  final activePath = getActiveProjectPath();
  final confirm =
      (ask(
                'Run DEEP CLEAN? This will delete all .g.dart files and build artifacts. (y/n)',
                defaultValue: 'n',
              ) ??
              'n')
          .toLowerCase() ==
      'y';
  if (!confirm) return;

  printInfo('Running Deep Clean in $activePath...');
  final libDir = Directory(p.join(activePath, 'lib'));
  if (libDir.existsSync()) {
    final List<FileSystemEntity> entities = libDir.listSync(recursive: true);
    int deletedCount = 0;
    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.g.dart')) {
        entity.deleteSync();
        deletedCount++;
      }
    }
    printSuccess('Deleted $deletedCount generated files.');
  }

  // runCommand already uses workingDirectory: activePath
  await runCommand('flutter', ['clean']);
  printSuccess('Build artifacts purged.');
  printInfo(
    'Deep clean complete. Run Build Runner to regenerate necessary files.',
  );
}
