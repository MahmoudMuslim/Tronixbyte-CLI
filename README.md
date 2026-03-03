# ⚡ TRONIXBYTE ELITE CLI
### *The Ultimate Engineering Engine for High-Velocity Flutter & Dart Development*

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean-green.svg?style=for-the-badge)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![AI Powered](https://img.shields.io/badge/AI-Powered-blue.svg?style=for-the-badge&logo=google-gemini&logoColor=white)](https://aistudio.google.com/app/apikey)

The **Tronixbyte CLI** is a professional-grade, project-agnostic power tool designed to automate the entire lifecycle of enterprise Flutter and Dart applications. It doesn't just scaffold code—it enforces strict architectural integrity, performs deep security audits according to OWASP standards, and manages complex multi-project environments from a single global binary.

---

## 🌎 GLOBAL WORKSTATION INTELLIGENCE
The Tronixbyte CLI is built to be a permanent part of your development environment. It doesn't live inside a project; it manages your entire workstation.

| System Capability | Visual | Description |
| :--- | :---: | :--- |
| **Persistent Active Context** | 🧠 | Tracks your "Active Project" globally across terminal sessions via `.tronix_history.json`. |
| **Smart Path Resolution** | 📍 | All file operations resolve to the absolute path of the managed project root. |
| **Multi-Project History** | 📜 | Built-in manager to switch contexts between recently created or managed projects instantly. |
| **Zero-Dependency Binary** | 📦 | Compiles to a single `.exe`. No Dart SDK required on target machines for execution. |
| **Terminal Agnostic** | 💻 | Seamless execution in CMD, PowerShell, Bash, and Zsh with consistent TUI. |

---

## 🚀 COMPREHENSIVE MODULE DEEP-DIVE

### 🏗️ 1. ARCHITECTURAL MASTERY (CLEAN ARCHITECTURE)
*Enforce a rock-solid, scalable foundation automatically. Stop fighting boilerplate and start building features.*

- **Elite Feature Scaffolder**: Generates full modular features with isolation between **Domain, Data, and Presentation**.
  - **Frameworks**: `bloc`, `cubit`, `riverpod`, `getx`, `provider`.
  - **Standard Folders**: Auto-generates `datasources`, `models`, `repositories`, `entities`, `usecases`, `screens`, `widgets`, and `managers`.
- **Recursive Barrel Synchronizer**: Automatically manages `z_*.dart` export files. This enables clean, single-line imports like `import 'package:app/features/home/z_home.dart';` instead of dozens of individual lines.
- **Smart Injection Wiring**: Automated registration of new features, repositories, and services in `lib/injection.dart` using `GetIt`.
- **Architecture Mapping**: Visualizes your project dependencies using **Mermaid.js** diagrams generated on the fly.
- **Architecture Linter**: Scans your import tree to ensure Domain remains pure and Data never leaks into the Presentation layer.

### 🛡️ 2. SECURITY, HARDENING & COMPLIANCE
*Protect your application and user data with automated security tools that think like an attacker.*

- **Deep Security Auditor**: Scans source code for OWASP violations, insecure storage (e.g., using SharedPreferences for sensitive tokens), and missing network protections.
- **Hardcoded Secret Extractor**: A "nuclear" utility that detects API keys and tokens in code, migrates them to `.env` files, and refactors your Dart source code to use `flutter_dotenv` automatically.
- **Security Scaffolding**: 
  - **SSL Pinning**: Scaffold Dio interceptors for certificate fingerprint verification to prevent Man-In-The-Middle (MITM) attacks.
  - **Biometric Auth**: Production-ready implementation of FaceID/TouchID via `local_auth`.
  - **Jailbreak/Root Detection**: Scaffolds device integrity verification services to restrict execution on compromised hardware.
- **Penetration Tester**: Simulates payload fuzzing and header injection attacks against your target endpoints to verify backend resilience.
- **Dependency Security Guard**: Audits `pubspec.lock` against global CVE databases (OSV.dev) to identify vulnerable packages before they are deployed.

### 🧪 3. ADVANCED TESTING & QUALITY ASSURANCE
*released with 100% confidence through automated verification suites.*

- **Smart Mock Architect**: Crawls your architecture and generates **Mocktail** mocks for all Repositories and DataSources found in your feature folders.
- **Widget Test Generator**: Automatically scaffolds widget tests for every screen found in your features, providing a baseline for UI verification.
- **Golden Test Designer**: Infrastructure setup for visual regression testing using **Alchemist**, ensuring your UI never breaks unexpectedly across versions.
- **Coverage Heatmap**: Provides a high-visibility ASCII heatmap of test coverage density across all features, highlighting untested logic at a glance.
- **Screenshot Automator**: Configures `integration_test` to capture professional app screenshots across multiple device sizes (iPhone 14 Pro Max, iPad Pro, etc.) automatically.
- **Visual Regression Suite**: Pixel-match comparison tool that detects visual changes between current builds and baselines, generating an interactive HTML report.

### 🌍 4. ASSETS & LOCALIZATION INTELLIGENCE
*Remove the manual labor from your asset and translation pipelines. Go global in minutes.*

- **AI Translator**: Uses **Google Gemini Pro** to translate your `en.json` into any target language instantly while preserving JSON keys and placeholders.
- **L10n Sync Tool**: Automatically synchronizes missing keys from your master language file to all other locales, marking them for review.
- **Smart Asset Optimizer**: Batch converts and optimizes images (PNG/JPG to WebP) with detailed reports on size reduction and performance gains.
- **Multi-Density Bundler**: Automatically generates `2.0x` and `3.0x` density variants for all your assets, ensuring crisp visuals on high-DPI screens.
- **Asset Constants Generator**: Scans your `assets/` folder and generates a type-safe `AppAssets` class for compile-time safe referencing.

### 📦 5. DEVOPS, DELIVERY & STORE AUTOMATION
*Automate the journey from your workstation to the App Stores.*

- **CI/CD Wizard**: Scaffolds professional GitHub Actions workflows for:
  - PR Quality Gates (Lint, Format, Test).
  - Auto-deploy to GitHub Pages (Web).
  - Shorebird Code Push automated patching.
  - Multi-Platform release builds (APK, AAB, IPA).
- **Shorebird Manager**: Full lifecycle control for **Shorebird Code Push** (Initialization, Login, Patching, and Release tracking).
- **Monorepo Manager**: Specialized tools for multi-package projects using **Melos**, including dependency graphing and nuclear workspace cleaning.
- **Fastlane Metadata Auditor**: Verifies Play Store and App Store metadata (titles, descriptions, screenshots) compliance against store character limits and requirements.
- **Multi-Build Hub**: Generate APK, AAB, IPA, and Web release bundles simultaneously from a single command.

### 📈 6. PROJECT ANALYTICS & SCALING
*Real-time insights into your development velocity and codebase health.*

- **Project Doctor**: Deep health diagnosis of project structure, mandatory files, dependencies, and environment synchronization.
- **Growth Forecaster**: Predictive modeling of project scale (LOC and Asset growth trends) based on historical snapshots captured over time.
- **Velocity Predictor**: Git-based analysis of development momentum to estimate release dates and track commit volume trends.
- **Code Metrics Dashboard**: Detailed breakdown of Business Logic vs UI code ratios, comment density, and architectural weight.
- **Behavioral Analytics Auditor**: Scans for event tracking coverage across features to ensure your marketing and product data is being captured.

---

## 💻 OPERATIONAL SHORTCUTS MATRIX
*Command animations and quick-reference actions for high-velocity engineering.*

| Command | Action / Effect | Visual State | Category |
| :--- | :--- | :---: | :--- |
| `tools <name> <type>` | Scaffold new Clean Arch feature | 🏗️ **Building...** | Scaffolding |
| `tools sync` | Align all links, barrels & dependencies | 🔄 **Syncing...** | Maintenance |
| `tools repair` | Nuclear re-wiring of architecture | ☢️ **Repairing...** | Recovery |
| `tools doctor` | Comprehensive health & integrity check | 🩺 **Diagnosing...** | Diagnosis |
| `tools audit` | Deep security, performance & OWASP scan | 🔍 **Auditing...** | Security |
| `tools quality` | Sequential Quality Gate execution | ✅ **Verifying...** | QA |
| `tools stats` | Real-time project complexity dash | 📊 **Analyzing...** | Metrics |
| `tools clean` | Nuclear project purge & refresh | 🧹 **Cleaning...** | System |
| `tools help` | Display documentation center | 📖 **Reading...** | Info |

---

## 🏗️ SUPPORTED TECHNICAL STACK
*The toolkit is designed to manage projects built with the following industry-standard stacks:*

| Tier | Standard / Technology | Implementation Recommendation |
| :--- | :--- | :--- |
| **Language** | Dart 3.x | Strong patterns, Records, and Null-Safety. |
| **Framework** | Flutter 3.x | Skia/Impeller support, Desktop, Web, Mobile. |
| **State** | Modular managers | BLoC (Hydrated), Riverpod, GetX, Provider. |
| **Navigation** | Type-safe routing | GoRouter Builder with absolute paths. |
| **Networking** | Functional API | Dio, Retrofit, Dartz (Functional Error Handling). |
| **Persistence** | Type-safe DB | Drift (SQLite), Secure Storage, SharedPreferences. |
| **Intelligence** | Generative AI | Google Gemini Pro 1.5 (via Official API). |
| **Delivery** | CI/CD | GitHub Actions, Fastlane, Shorebird Code Push. |

---

## 🗺️ PROJECT ELITE ROADMAP

### 🏆 Phase 21: The Global Leap (COMPLETED)
*Status: Production Ready*

| 🚀 Milestone | 🛰️ Status | 📊 Progress |
| :--- | :---: | :--- |
| **Workstation Context Decoupling** | ✅ | [████████████████████] 100% |
| **Persistent Project Memory** | ✅ | [████████████████████] 100% |
| **Nuclear Project Repairer** | ✅ | [████████████████████] 100% |
| **Hardcoded Secret Extractor & Refactor** | ✅ | [████████████████████] 100% |
| **Gemini Localization AI Integration** | ✅ | [████████████████████] 100% |
| **Elite Security Scaffolding (SSL/Bio)** | ✅ | [████████████████████] 100% |
| **Monorepo (Melos) Integration** | ✅ | [████████████████████] 100% |
| **Recursive Barrel Management** | ✅ | [████████████████████] 100% |
| **Multi-Build Release Hub** | ✅ | [████████████████████] 100% |
| **Growth & Velocity Prediction Engine** | ✅ | [████████████████████] 100% |
| **Project Doctor (Health Diagnosis)** | ✅ | [████████████████████] 100% |
| **Asset Optimization Suite** | ✅ | [████████████████████] 100% |
| **Visual Regression Suite (HTML Report)** | ✅ | [████████████████████] 100% |
| **API Mock Server (Auto-Gen)** | ✅ | [████████████████████] 100% |

### 🛰️ Phase 22 & 23: Intelligence & Automation (IN PROGRESS)
*Status: Active Development*

| 🛠️ Task | 📡 Status | 📈 Progress |
| :--- | :---: | :--- |
| **AI-Powered "Architect" Mode** | 🚧 | [██████░░░░░░░░░░░░░░] 30% |
| **Natural Language Blueprinting** | 🚧 | [████░░░░░░░░░░░░░░░░] 20% |
| **Context-Aware Logic Synthesis** | 🚧 | [██░░░░░░░░░░░░░░░░░░] 10% |
| **"Ghost" Integration Test Recorder** | 🚧 | [██░░░░░░░░░░░░░░░░░░] 10% |
| **Deep AST Memory Leak Auditor** | 🚧 | [████████░░░░░░░░░░░░] 40% |
| **Real-Time TUI Engineering Dashboard** | 🚧 | [████████████░░░░░░░░] 60% |
| **Dynamic CLI Plugin System** | 🚧 | [████░░░░░░░░░░░░░░░░] 20% |
| **License Compliance GPL Guard** | ⏳ | [░░░░░░░░░░░░░░░░░░░░] 0% |
| **Intelligent Dependency Resolver** | ⏳ | [░░░░░░░░░░░░░░░░░░░░] 0% |

### 🔭 Phase 24 - 25: Strategic Frontiers (FUTURE)
*Status: Research & Planning*

- [ ] **Enterprise Whitelabeling System**: Automated multi-brand asset orchestration and flavor code-gen.
- [ ] **Design System Bridge (TUI)**: Terminal-based Material 3 token designer and Figma API synchronization.
- [ ] **Post-Quantum Security Module**: Advanced logic flow obfuscation and hardware-backed secure enclave integration.
- [ ] **Automated Feature Documentation**: Generate detailed READMEs for each modular feature based on its internal logic.
- [ ] **Visual Assertion Engine**: Automatically generate UI assertions based on recorded flow snapshots.
- [ ] **Cross-Device Playback Matrix**: Matrix orchestrator for integration tests across varied hardware profiles.

---

## 🏛️ SYSTEM ARCHITECTURE & INTERNALS
The toolkit is designed as a **Universal Dart Binary**, optimized for high-performance workstation execution.

### Directory Structure Overview
```text
tools/
├── bin/
│   └── tools.dart           # Primary Entry Point & Argument Dispatcher
├── lib/src/
│   ├── config/              # Orchestrators for Firebase, DB, and Network
│   ├── features/            # Clean Architecture scaffolding engines
│   ├── menus/               # Hierarchical Terminal UI (TUI) definitions
│   ├── project/             # Creation logic for new Flutter/Dart apps
│   ├── templates/           # Industry-standard boilerplate library
│   └── utils/
│       ├── app/             # Global Context, History, and Path Engines
│       ├── security/        # OWASP Auditing, Extraction, and Hardening
│       ├── testing/         # Mocks, Goldens, Heatmaps, and Screenshots
│       ├── project/         # Doctor, Repair, Stats, and Forecasting
│       └── l10n/            # Gemini AI Translation and Sync
```

### Path Resolution Logic
The core of the toolkit's project-agnosticism lies in its absolute path engine.
1.  **Context Detection**: Uses `.tronix_history.json` to identify the current target project and its root.
2.  **Working Directory**: The `runCommand()` utility executes shell processes (flutter, dart, git) directly within the target project's absolute working directory.
3.  **Strict Isolation**: Every internal `dart:io` call uses `path.join(activePath, ...)` to ensure the CLI remains project-agnostic and never modifies its own installation folder accidents. This allows you to run `tools` from anywhere on your OS.

---

## 🛠️ INSTALLATION & GLOBAL SETUP

### 1. Clone the Engine
```sh
git clone https://github.com/tronixbyte/tools.git
cd tools
dart pub get
```

### 2. Build for Global Use
To use the toolkit from any terminal, compile it to a standalone executable:
```sh
dart compile exe bin/tools.dart -o tools.exe
```

### 3. Add to System PATH
- **Windows**: Add the folder containing `tools.exe` to your **User Path** environment variable via System Settings.
- **macOS/Linux**: `mv tools.exe /usr/local/bin/tools` or add an alias to your shell profile (`.zshrc` / `.bashrc`):
  ```sh
  alias tools='/path/to/your/tools.exe'
  ```

---

## 🤝 CONTRIBUTING & QUALITY STANDARDS
The Tronixbyte CLI follows strict quality standards. To contribute to this project:
1. Ensure your code passes the built-in quality gate: `tools quality`.
2. All new utilities must be context-aware (using `activePath` via `getActiveProjectPath()`).
3. Document new features in the corresponding `z_*.dart` barrels for clean exports.
4. Maintain the workstation-level abstraction—never assume `Directory.current` is the target project.

### Professional Code Style
- **Naming**: Use `snake_case` for files and `PascalCase` for classes.
- **Patterns**: Prefer Functional Error Handling (Dartz) for domain logic.
- **Testing**: All new features should include a corresponding unit or widget test where applicable.

---

## 🛡️ LICENSE
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
*Developed by **Tronixbyte Engineering** for the next generation of Flutter engineers who build scalable, secure, and high-performance applications.*

---
*(End of documentation - 300+ lines of Elite Flutter Engineering Intelligence)*
