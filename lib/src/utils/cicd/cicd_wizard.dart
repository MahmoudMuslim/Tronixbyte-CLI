import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> configureCiCd() async {
  printSection('🚀 Multi-Platform CI/CD Generator');

  final activePath = getActiveProjectPath();
  final projectName = await getProjectName();

  final options = [
    'GitHub Actions (Default)',
    'GitLab CI (Coming Soon)',
    'Bitbucket Pipelines (Coming Soon)',
  ];

  final choice = selectOption('Select CI/CD Platform', options, showBack: true);
  if (choice == 'back' || choice == null) return;

  if (choice == '1') {
    await _configureGitHubActions(projectName, activePath);
  } else {
    printInfo('Platform integration coming soon.');
  }
}

Future<void> _configureGitHubActions(
  String projectName,
  String activePath,
) async {
  final workflowsDir = Directory(p.join(activePath, '.github', 'workflows'));
  if (!workflowsDir.existsSync()) workflowsDir.createSync(recursive: true);

  print('\n$blue$bold📦 Select Pipeline Workflows:$reset');

  final options = [
    'Automated Testing & Linting (on PR)',
    'Auto-deploy to GitHub Pages (Web)',
    'Shorebird Code Push (Auto-patch)',
    'Firebase App Distribution (Staging)',
    'Multi-Platform Release (Build & Artifacts)',
  ];

  final choices = <int>[];
  for (var i = 0; i < options.length; i++) {
    final enable =
        (ask('${i + 1}: ${options[i]}? (y/n)') ?? 'n').toLowerCase() == 'y';
    if (enable) choices.add(i + 1);
  }

  await loadingSpinner('Scaffolding CI/CD Workflows', () async {
    if (choices.contains(1)) await _generateQualityWorkflow(activePath);
    if (choices.contains(2)) {
      await _generateWebWorkflow(projectName, activePath);
    }
    if (choices.contains(3)) await _generateShorebirdWorkflow(activePath);
    if (choices.contains(4)) await _generateFirebaseWorkflow(activePath);
    if (choices.contains(5)) await _generateFullReleaseWorkflow(activePath);
  });

  printSuccess(
    'CI/CD Workflows successfully generated in ${workflowsDir.path}',
  );
  ask('Press Enter to return');
}

Future<void> _generateQualityWorkflow(String activePath) async {
  final content = getGenerateQualityWorkflowTemplate();
  File(
    p.join(activePath, '.github/workflows/quality.yml'),
  ).writeAsStringSync(content.trim());
}

Future<void> _generateWebWorkflow(String name, String activePath) async {
  final content = getGenerateWebWorkflowTemplate(name);
  File(
    p.join(activePath, '.github/workflows/deploy_web.yml'),
  ).writeAsStringSync(content.trim());
}

Future<void> _generateShorebirdWorkflow(String activePath) async {
  final content = getGenerateShorebirdWorkflowTemplate();
  File(
    p.join(activePath, '.github/workflows/shorebird_patch.yml'),
  ).writeAsStringSync(content.trim());
}

Future<void> _generateFirebaseWorkflow(String activePath) async {
  final content = getGenerateFirebaseWorkflowTemplate();
  File(
    p.join(activePath, '.github/workflows/firebase_dist.yml'),
  ).writeAsStringSync(content.trim());
}

Future<void> _generateFullReleaseWorkflow(String activePath) async {
  final content = getGenerateFullReleaseWorkflowTemplate();
  File(
    p.join(activePath, '.github/workflows/release.yml'),
  ).writeAsStringSync(content.trim());
}
