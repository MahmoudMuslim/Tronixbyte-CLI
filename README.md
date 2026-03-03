# Tronixbyte Project CLI

This directory contains a powerful, self-contained Dart command-line interface (CLI) to automate, manage, and accelerate development of this Flutter project.

It's built to enforce Clean Architecture, ensure consistency, and handle tedious tasks, allowing developers to focus on building features.

## 🚀 Core Features

- **Feature Scaffolding**: Generate entire features with full Clean Architecture layers (Data, Domain, Presentation) for various state management solutions (BLoC, Cubit, Riverpod, etc.).
- **Code Generation**: Automatically create models, mappers, API endpoints, routes, and more.
- **Project Maintenance**: A suite of tools to keep the project healthy.
  - `doctor`: Diagnose the project for structural and configuration issues.
  - `repair`: Run a "nuclear" fix to resolve common problems.
  - `sync`: A one-stop command to get dependencies, run build runners, and generate localization keys.
- **Code Quality & Auditing**: Run linters, formatters, test suites, and security audits.
- **Configuration Hub**: Interactively configure everything from Firebase and AdMob to themes and native splash screens.
- **Build & Release Automation**: Tools to manage app versions, generate changelogs, and create release builds.

## 🛠️ How to Use

Run the CLI from the project root directory.

### Interactive Menu

For an interactive experience that guides you through all available options, simply run:

```sh
dart bin/tools.dart
```

### Quick Commands (Shortcuts)

For common tasks, you can use direct shortcuts:

```sh
# Generate a new feature named 'login' using BLoC
dart bin/tools.dart login bloc

# Run the full project sync
dart bin/tools.dart sync

# Run the project doctor
dart bin/tools.dart doctor

# Run the code quality suite
dart bin/tools.dart quality
```

To see all available shortcuts, run `dart bin/tools.dart help`.

---
*This tool is an integral part of the project's development ecosystem. For more technical details, see `tools/DOCS.md`.*