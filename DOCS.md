# ⚡ Tronixbyte CLI Technical Documentation

This document provides a deep technical overview of the **Tronixbyte Elite CLI Toolkit** architecture, modules, and internal implementation details.

---

## 🏛️ System Architecture

The toolkit is designed as a **Universal Dart Binary**, optimized for global workstation-level execution. It operates independently of the project it manages by utilizing a persistent global context.

### Core Directory Structure

- `bin/`: The primary entry point (`tools.dart`). Handles CLI arguments and interactive menu routing.
- `lib/src/config/`: Orchestrates complex project-wide setup logic (Firebase, Shorebird, Databases, Networking).
- `lib/src/features/`: The engine for **Clean Architecture** scaffolding. Contains logic for creating, renaming, and deleting modular features.
- `lib/src/menus/`: Defines the hierarchical interactive terminal UI (TUI) structures.
- `lib/src/project/`: Handles the creation of new Flutter and Dart projects from standardized Tronixbyte templates.
- `lib/src/templates/`: A comprehensive library of high-quality code templates for BLoC, Cubit, Repositories, UseCases, UI Components, and CI/CD workflows.
- `lib/src/utils/`: The core functional logic of the toolkit, divided into specialized domains:
  - `app/`: Low-level CLI utilities (Console I/O, Path Tracking, History Management, Process Runners).
  - `assets/`: Image optimization, multi-density bundling, and constant generation.
  - `barrel/`: Recursive directory crawling and `z_*.dart` export management.
  - `cicd/`: GitHub Actions and Git Hook automation.
  - `code/`: Quality gates, complexity auditing, metrics, and test scaffolding.
  - `dependency/`: Architectural isolation linters, circular dependency detection, and security scans.
  - `env/`: Multi-environment switcher and secret extraction wizards.
  - `firebase/`: Full-stack Firebase integration and platform-specific manifest configuration.
  - `ide/`: VS Code integration (Tasks, Launch configs, Snippets) and Changelog generation.
  - `l10n/`: AI-powered translation (Gemini) and localization synchronization.
  - `project/`: High-level management (Doctor, Repair, Growth Forecasting, Visual Regression).
  - `shorebird/`: Code Push lifecycle automation.

---

## 🌎 Global execution & Path Resolution

One of the most critical technical features of the toolkit is its **Global Project Context**.

### Internal Path Handling
- **`getActiveProjectPath()`**: A centralized utility that retrieves the absolute path of the project currently being managed.
- **`runCommand()`**: A robust wrapper around `Process.run/start` that automatically sets the `workingDirectory` to the active project root.
- **Absolute Resolution**: Every file read/write operation (`dart:io`) uses `path.join(activePath, ...)` to ensure the CLI remains project-agnostic and never modifies its own installation directory.

### Persistent History
The CLI utilizes a `.tronix_history.json` file (stored in the toolkit root) to remember:
1. The **Active Project** path.
2. A history of **Recently Managed Projects**.
3. Cached project metadata (e.g., project names).

---

## 🚀 Key Implementation Details

### 1. Clean Architecture Scaffolding
The scaffolder uses a multi-layered template approach. When a feature is created, it:
1. Generates the folder hierarchy (`data`, `domain`, `presentation`).
2. Injects the project name into imports using `getProjectName()`.
3. Automatically triggers the **Barrel Synchronizer** to link the new feature.
4. Triggers `wireFeatureInjection` to add the feature to the global `GetIt` container.

### 2. Recursive Barrel Management
The `BarrelGenerator` uses a bottom-up recursive strategy:
- It crawls every directory in `lib/`.
- It identifies regular Dart files and existing sub-barrels.
- It generates a `z_<folder_name>.dart` file containing sorted exports.
- This creates a "Tree of Barrels" where importing the top-level barrel provides access to all children.

### 3. AI Intelligence (Google Gemini)
The toolkit integrates the `google_generative_ai` package to provide:
- **Contextual Translation**: Translates JSON localization files while strictly maintaining keys and placeholders.
- **Future Integration**: Planned AI blueprinting to generate entire feature layers from natural language descriptions.

### 4. Security & Hardening
- **Hardcoded Secret Extractor**: Uses complex Regular Expressions to find entropy-heavy strings. It not only extracts them to `.env` but also performs **Source Code Refactoring** to inject the necessary `flutter_dotenv` logic.
- **SSL Pinning**: Scaffolds a custom `Dio` interceptor foundation that enforces SHA-256 fingerprint validation at the network layer.

### 5. Multi-Repo (Monorepo) Engine
Specialized support for workspaces using **Melos**:
- **Cross-Package Synchronization**: Runs commands (clean, pub get, test) across all discovered packages.
- **Graph Visualization**: Generates Graphviz DOT files representing the internal dependencies between local packages.

---

## 🛠️ Developer Contribution Guide

### Adding a New Utility
1. Create the logic file in the appropriate `lib/src/utils/<domain>/` directory.
2. Export the main function in the domain's `z_<domain>.dart` barrel.
3. Ensure the function uses `getActiveProjectPath()` for any file I/O.
4. Use `runCommand` for shell execution.
5. Register the new utility in the relevant menu file within `lib/src/menus/`.

### Re-compiling the Binary
Whenever changes are made to the source, the global binary must be updated:
```sh
dart compile exe bin/tools.dart -o tools.exe
```

---
*Developed and maintained by the Tronixbyte Engineering Team.*
