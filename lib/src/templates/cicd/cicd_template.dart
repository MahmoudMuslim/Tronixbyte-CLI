String getGenerateQualityWorkflowTemplate() => """
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

String getGenerateWebWorkflowTemplate(String name) =>
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

String getGenerateShorebirdWorkflowTemplate() => """
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

String getGenerateFirebaseWorkflowTemplate() => """
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

String getGenerateFullReleaseWorkflowTemplate() => """
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

String getMonoRepoMelosTemplate() {
  return """
name: my_monorepo
packages:
- packages/*
- .
""";
}
