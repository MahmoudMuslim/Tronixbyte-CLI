# Tronixbyte CLI Documentation

This document provides a technical overview of the tools and utilities available in the `tools/` directory.

## 📁 Architecture of the Tools

The CLI is structured into several directories for modularity:

- `src/config/`: Handles project-wide configurations (Network, Database, Firebase, Shorebird, etc.).
- `src/features/`: Contains the logic and templates for feature generation, renaming, and deletion.
- `src/menus/`: Defines the interactive CLI menu structures.
- `src/project/`: Core logic for creating new Flutter or Dart projects with the Tronixbyte template.
- `src/setup/`: Manages the full project initialization process.
- `src/utils/`: A collection of utility scripts for project maintenance, auditing, and synchronization.

## 🛠️ Detailed Command Overview

### 1. Feature Generation (`src/features/`)

Generates a complete feature directory structure under `lib/features/<name>/`.
- **Supported State Management**: BLoC, Cubit, Riverpod, GetX, Provider.
- **Layers Generated**: Data (datasources, models, repositories), Domain (entities, usecases, repositories), Presentation (screens, widgets), and Injection.
- **Auto-Wiring**: Automatically adds the new feature to the project's dependency injection and routing systems.

### 2. Project Synchronization (`src/utils/sync_manager.dart`)

The `sync` command orchestrates several sub-tasks:
1. `flutter pub get`: Fetches dependencies.
2. `generateBarrelFiles`: Scans the project and creates/updates `z_*.dart` barrel files for clean exports.
3. `build_runner`: Runs the code generator for Drift, Retrofit, JsonSerializable, etc.
4. `easy_localization`: Generates localization keys from JSON assets.
5. `dart format`: Ensures all code follows standard formatting.

### 3. Project Doctor & Repair (`src/utils/project_doctor.dart` & `project_repairer.dart`)

- **Doctor**: Scans the project for missing directories, files, environment variables, and architectural violations.
- **Repair**: A more aggressive tool that attempts to fix issues found by the Doctor, including resetting generated files and rebuilding broken links.

### 4. Security & Performance Audits (`src/utils/security_auditor.dart` & `performance_auditor.dart`)

- **Security**: Scans for hardcoded API keys, secrets in the source code, and ensures `.env` files are properly ignored.
- **Performance**: Analyzes asset sizes, dependency weights, and common performance pitfalls in Flutter.

## 🚀 Technical Implementation

The CLI is written in pure Dart and uses `dart:io` for file system operations and process management. It relies on the `path` package for cross-platform path handling.

### Key Utilities

- `utils.dart`: Contains shared functions for running shell commands (`runCommand`), prompting users (`ask`), and project-wide constants (base dependencies, etc.).
- `barrel_generator.dart`: Uses recursive directory traversal to maintain barrel files, simplifying imports across the project.

---
*Maintained by the Tronixbyte Development Team.*
