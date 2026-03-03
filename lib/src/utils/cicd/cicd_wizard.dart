import 'package:tools/tools.dart';

Future<void> configureCiCd() async {
  printSection('🚀 Multi-Platform CI/CD Generator');

  final projectName = await getProjectName();

  final options = [
    'GitHub Actions (Default)',
    'GitLab CI (Coming Soon)',
    'Bitbucket Pipelines (Coming Soon)',
  ];

  final choice = selectOption('Select CI/CD Platform', options, showBack: true);
  if (choice == 'back' || choice == null) return;

  if (choice == '1') {
    await _configureGitHubActions(projectName);
  } else {
    printInfo('Platform integration coming soon.');
  }
}

Future<void> _configureGitHubActions(String projectName) async {
  final workflowsDir = Directory('.github/workflows');
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
    if (choices.contains(1)) await _generateQualityWorkflow();
    if (choices.contains(2)) await _generateWebWorkflow(projectName);
    if (choices.contains(3)) await _generateShorebirdWorkflow();
    if (choices.contains(4)) await _generateFirebaseWorkflow();
    if (choices.contains(5)) await _generateFullReleaseWorkflow();
  });

  printSuccess('CI/CD Workflows successfully generated in .github/workflows/');
  ask('Press Enter to return');
}

Future<void> _generateQualityWorkflow() async {
  final content = """
name: Quality & Testing

on:
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - name: Install dependencies
        run: flutter pub get
      - name: Analyze
        run: flutter analyze
      - name: Run Tests
        run: flutter test --coverage
""";
  File('.github/workflows/quality.yml').writeAsStringSync(content.trim());
}

Future<void> _generateWebWorkflow(String name) async {
  final content =
      """
name: Deploy Web

on:
  push:
    tags: [ 'v*' ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - name: Build
        run: flutter build web --release --base-href "/$name/"
      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: \${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
""";
  File('.github/workflows/deploy_web.yml').writeAsStringSync(content.trim());
}

Future<void> _generateShorebirdWorkflow() async {
  final content = """
name: Shorebird Patch

on:
  push:
    branches: [ main ]

jobs:
  patch:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: shorebirdtech/setup-shorebird@v0
      - name: Patch
        run: shorebird patch android --force
        env:
          SHOREBIRD_TOKEN: \${{ secrets.SHOREBIRD_TOKEN }}
""";
  File(
    '.github/workflows/shorebird_patch.yml',
  ).writeAsStringSync(content.trim());
}

Future<void> _generateFirebaseWorkflow() async {
  final content = """
name: Firebase Distribution

on:
  push:
    branches: [ develop ]

jobs:
  distribute:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - name: Build
        run: flutter build apk --release
      - name: Upload
        uses: w9jds/firebase-action@master
        with:
          args: appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk --app \${{ secrets.FIREBASE_ANDROID_APP_ID }}
        env:
          FIREBASE_TOKEN: \${{ secrets.FIREBASE_TOKEN }}
""";
  File('.github/workflows/firebase_dist.yml').writeAsStringSync(content.trim());
}

Future<void> _generateFullReleaseWorkflow() async {
  final content = """
name: Multi-Platform Release

on:
  push:
    tags: [ 'v*' ]

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
    runs-on: \${{ matrix.os }}
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - name: Build All
        run: |
          if [ "\${{ matrix.os }}" == "ubuntu-latest" ]; then
            flutter build apk --release
            flutter build appbundle --release
          else
            flutter build ios --release --no-codesign
          fi
      - name: Release
        uses: softprops/action-gh-release@v1
        with:
          files: build/app/outputs/flutter-apk/*.apk
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
""";
  File('.github/workflows/release.yml').writeAsStringSync(content.trim());
}
