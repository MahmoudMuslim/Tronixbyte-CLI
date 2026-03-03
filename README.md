# ⚡ TRONIXBYTE ELITE CLI
### *The Ultimate Project-Agnostic Engineering Engine for Flutter & Dart*

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean-green.svg?style=for-the-badge)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![AI Powered](https://img.shields.io/badge/AI-Powered-blue.svg?style=for-the-badge&logo=google-gemini&logoColor=white)](https://aistudio.google.com/app/apikey)

The **Tronixbyte CLI** is an enterprise-grade power tool designed to manage your entire workstation's Flutter and Dart ecosystem. It doesn't just live in your project; it manages your workstation, enforcing **Clean Architecture**, ensuring **Production Readiness**, and handling **Complex Automation** from a single global command.

---

## 🌎 GLOBAL WORKSTATION INTELLIGENCE
The Tronixbyte CLI operates at the system level, providing a persistent management layer across all your projects.

| 🧩 System Capability | 🔮 Visual | ⚙️ Implementation Detail |
| :--- | :---: | :--- |
| **Persistent Active Context** | 🧠 | Maintains global state of your "Active Project" across terminal sessions via `.tronix_history.json`. |
| **Smart Path Resolution** | 📍 | All file operations (scaffold, audit, sync) resolve to the absolute path of the managed project root. |
| **Multi-Project History** | 📜 | Built-in manager to switch contexts between recently created or managed projects instantly. |
| **Universal Dart Binary** | 📦 | Compiles to a single `.exe`. No Dart SDK required on target machines for execution. |
| **Terminal Agnostic** | 💻 | Native high-performance execution in CMD, PowerShell, Bash, and Zsh. |

---

## 🚀 COMPREHENSIVE MODULE DEEP-DIVE

### 🏗️ 1. PROJECT INITIATION & SCAFFOLDING
*Standardize your project foundations from day one.*
- **Flutter Create Elite**: A specialized wizard that sets up projects with enterprise standards (org naming, description, platforms, and clean templates).
- **Dart Scaffolder**: Rapidly bootstrap CLI tools, Console apps, or Server-side (Shelf) projects.
- **Auto-Handover**: New projects are immediately added to the global active context for further automation.

### 🏛️ 2. ARCHITECTURAL MASTERY (CLEAN ARCHITECTURE)
*Enforce a rock-solid, scalable foundation automatically.*
- **Elite Feature Scaffolder**: Generates full modular features with isolation between **Domain, Data, and Presentation**.
  - **Frameworks**: `bloc`, `cubit`, `riverpod`, `getx`, `provider`.
  - **Standard Folders**: `datasources`, `models`, `repositories`, `entities`, `usecases`, `screens`, `widgets`, and `managers`.
- **Recursive Barrel Synchronizer**: Automatically manages `z_*.dart` export files. This enables clean imports like `import 'package:app/features/home/z_home.dart';` instead of 50 individual imports.
- **Smart Injection Wiring**: Automated registration of new features and services in `lib/injection.dart` using `GetIt`.
- **Architecture Visualizer**: Generates **Mermaid.js** diagrams showing the dependency graph between features.
- **Architecture Linter**: Scans imports to ensure Domain remains pure and Data never leaks into Presentation.

### 🛡️ 3. SECURITY, HARDENING & COMPLIANCE
*Protect your application and user data with automated security tools.*
- **Deep Security Auditor**: Scans source code for OWASP violations, insecure storage, and missing network protections.
- **Hardcoded Secret Extractor**: Detects API keys and tokens in code, migrates them to `.env` files, and refactors code to use `flutter_dotenv` automatically.
- **Security Scaffolding**: 
  - **SSL Pinning**: Scaffold Dio interceptors for certificate fingerprint verification to prevent MITM attacks.
  - **Biometric Auth**: Production-ready implementation of FaceID/TouchID via `local_auth`.
  - **Jailbreak/Root Detection**: Scaffolds device integrity verification services.
- **Penetration Tester**: Simulates payload fuzzing and header injection attacks against your target endpoints.
- **Dependency Security Guard**: Audits `pubspec.lock` against CVE databases (OSV.dev).

### 🧪 4. ADVANCED TESTING & QUALITY ASSURANCE
*High-velocity testing automation for high-confidence releases.*
- **Smart Mock Architect**: Crawls your architecture and generates **Mocktail** mocks for all Repositories and DataSources.
- **Widget Test Generator**: Automatically scaffolds widget tests for every screen found in your features.
- **Golden Test Designer**: Infrastructure setup for visual regression testing using **Alchemist**.
- **Coverage Heatmap**: High-visibility ASCII heatmap of test coverage density across all features.
- **Screenshot Automator**: Configures `integration_test` to capture app screenshots across device sizes (iPhone 14 Pro Max, iPad Pro, etc.) automatically.
- **Global Quality Gate**: Single command (`tools quality`) to format, fix, analyze, and test your entire project.

### ⚙️ 5. INFRASTRUCTURE & CORE SERVICES
*Inject standard infrastructure services into any project in seconds.*
- **Network Service**: Reactive connectivity monitoring with `connectivity_plus`.
- **Storage Service**: Unified manager for `SharedPreferences` (settings) and `FlutterSecureStorage` (tokens).
- **Logger Service**: Professional, color-coded logging using the `logger` package.
- **Permission Service**: Centralized handler for system permissions via `permission_handler`.

### 🌍 6. ASSETS & LOCALIZATION INTELLIGENCE
*Remove the manual labor from your asset and translation pipelines.*
- **AI Translator**: Uses **Google Gemini Pro** to translate your `en.json` into any target language instantly while preserving keys and placeholders.
- **L10n Sync Tool**: Automatically synchronizes missing keys from your master language file to all other locales.
- **Smart Asset Optimizer**: Batch converts and optimizes images (PNG/JPG to WebP) with detailed size reduction reports.
- **Multi-Density Bundler**: Automatically generates `2.0x` and `3.0x` variants for all your assets.
- **Asset Constants Generator**: Generates a type-safe `AppAssets` class for compile-time safe referencing.

### 📦 7. DEVOPS, DELIVERY & STORE AUTOMATION
*Automate the journey from your workstation to the App Stores.*
- **CI/CD Wizard**: Scaffolds professional GitHub Actions for:
  - PR Quality Gates (Lint & Test).
  - Auto-deploy to GitHub Pages (Web).
  - Shorebird Code Push automated patching.
  - Multi-Platform release builds (APK, AAB, IPA).
- **Shorebird Manager**: Full lifecycle management for **Shorebird Code Push** (Initialization, Patching, and Release tracking).
- **Monorepo Manager**: Specialized tools for multi-package projects using **Melos**, including version syncing and workspace cleaning.
- **Fastlane Metadata Auditor**: Verifies Play Store and App Store metadata (titles, descriptions, screenshots) compliance.
- **Multi-Build Hub**: Generate APK, AAB, IPA, and Web release bundles simultaneously.

### 📈 8. PROJECT ANALYTICS & SCALING
*Real-time insights into your development velocity and code health.*
- **Project Doctor**: Deep health diagnosis of project structure, files, dependencies, and environment synchronization.
- **Growth Forecaster**: Predictive modeling of project scale (LOC and Asset growth trends) based on historical snapshots.
- **Velocity Predictor**: Git-based analysis of development momentum to estimate release dates.
- **Code Metrics Dashboard**: Detailed breakdown of Business Logic vs UI code ratios.

---

## 💻 OPERATIONAL SHORTCUTS MATRIX
*Command animations and quick-reference actions.*

| Command | Action / Effect | Visual State | Category |
| :--- | :--- | :---: | :--- |
| `tools <name> <type>` | Scaffold new feature | 🏗️ | Scaffolding |
| `tools sync` | Align all links & dependencies | 🔄 | Maintenance |
| `tools repair` | Nuclear re-wiring of architecture | ☢️ | Recovery |
| `tools doctor` | Comprehensive health check | 🩺 | Diagnosis |
| `tools audit` | Deep security & OWASP scan | 🔍 | Security |
| `tools quality` | Sequential Quality Gate execution | ✅ | QA |
| `tools stats` | Real-time project complexity dash | 📊 | Metrics |
| `tools clean` | Nuclear project purge & refresh | 🧹 | System |
| `tools help` | Display documentation center | 📖 | Info |

---

## 🛠️ INSTALLATION & GLOBAL SETUP

### 1. Build the Engine
```sh
git clone https://github.com/tronixbyte/tools.git
cd tools
dart pub get
dart compile exe bin/tools.dart -o tools.exe
```

### 2. Configure Global Access
- **Windows**: Add the folder containing `tools.exe` to your **User Path** environment variable.
- **macOS/Linux**: `mv tools.exe /usr/local/bin/tools` or add an alias to your shell profile (`.zshrc` / `.bashrc`).

---

## 🏗️ SUPPORTED TECHNICAL STACK
| Tier | Standard / Technology | Recommendation |
| :--- | :--- | :--- |
| **Language** | Dart 3.x | Patterns, Records, Strong Null-Safety |
| **Framework** | Flutter 3.x | Skia/Impeller, Desktop, Web, Mobile |
| **State** | Modular managers | BLoC, Riverpod, GetX, Provider |
| **Navigation** | Type-safe routing | GoRouter Builder |
| **Networking** | Functional API | Dio, Retrofit, Dartz |
| **Persistence** | Type-safe DB | Drift (SQLite), Secure Storage |
| **Intelligence** | GenAI | Google Gemini Pro 1.5 |
| **Delivery** | Automation | GitHub Actions, Fastlane, Shorebird |

---

## 🗺️ PROJECT TASK TRACKER & ROADMAP

### 🏆 Phase 21: The Global Leap (COMPLETED)
| 🚀 Milestone | 🛰️ Status | 📊 Progress |
| :--- | :---: | :--- |
| **Workstation Context Decoupling** | ✅ | [████████████████████] 100% |
| **Persistent Project Memory** | ✅ | [████████████████████] 100% |
| **Nuclear Project Repairer** | ✅ | [████████████████████] 100% |
| **Hardcoded Secret Extractor** | ✅ | [████████████████████] 100% |
| **AI Translation (Gemini)** | ✅ | [████████████████████] 100% |
| **Elite Security Scaffolding** | ✅ | [████████████████████] 100% |
| **Monorepo (Melos) Integration** | ✅ | [████████████████████] 100% |
| **Recursive Barrel Management** | ✅ | [████████████████████] 100% |
| **Multi-Build Release Hub** | ✅ | [████████████████████] 100% |
| **Growth & Velocity Prediction** | ✅ | [████████████████████] 100% |
| **Project Doctor (Diagnosis)** | ✅ | [████████████████████] 100% |
| **Asset Optimization Suite** | ✅ | [████████████████████] 100% |

### 🛰️ Phase 22 & 23: Intelligence & Automation (IN PROGRESS)
| 🛠️ Task | 📡 Status | 📈 Progress |
| :--- | :---: | :--- |
| **AI-Powered "Architect" Mode** | 🚧 | [██████░░░░░░░░░░░░░░] 30% |
| **"Ghost" Integration Test Recorder** | 🚧 | [██░░░░░░░░░░░░░░░░░░] 10% |
| **Deep AST Memory Leak Auditor** | 🚧 | [████████░░░░░░░░░░░░] 40% |
| **Real-Time TUI Dashboard** | 🚧 | [████████████░░░░░░░░] 60% |
| **Dynamic CLI Plugin System** | 🚧 | [████░░░░░░░░░░░░░░░░] 20% |
| **License Compliance GPL Guard** | ⏳ | [░░░░░░░░░░░░░░░░░░░░] 0% |

### 🔭 Phase 24 - 25: Strategic Frontiers (FUTURE)
- [ ] **Enterprise Whitelabeling System**: Automated multi-brand asset orchestration and flavor code-gen.
- [ ] **Design System Bridge (TUI)**: Terminal-based Material 3 token designer and Figma API synchronization.
- [ ] **Post-Quantum Security Module**: Advanced logic flow obfuscation and hardware-backed secure enclave integration.
- [ ] **Automated Feature Documentation**: Generate detailed READMEs for each modular feature based on its logic.
- [ ] **API Mock Server (Self-Hosting)**: Auto-generate a local Shelf-based mock server from your ApiService definitions.

---

## 🏛️ SYSTEM ARCHITECTURE
The toolkit is designed as a **Universal Dart Binary**, optimized for high-performance workstation execution.

```text
tools/
├── bin/tools.dart           # Primary Entry Point & Argument Dispatcher
├── lib/src/
│   ├── config/              # Orchestrators for Firebase, DB, and Network
│   ├── features/            # Clean Architecture scaffolding engines
│   ├── menus/               # Hierarchical Terminal UI (TUI) definitions
│   ├── templates/           # Industry-standard boilerplate library
│   └── utils/
│       ├── app/             # Global Context, History, and Path Engines
│       ├── security/        # OWASP Auditing, Extraction, and Hardening
│       ├── testing/         # Mocks, Goldens, Heatmaps, and Screenshots
│       ├── project/         # Doctor, Repair, Stats, and Forecasting
│       └── l10n/            # Gemini AI Translation and Sync
```

### Absolute Path Resolution Engine
The core of the toolkit's project-agnosticism lies in its absolute path engine.
1.  **`getActiveProjectPath()`**: Retrieves the system-wide active context from persistent history.
2.  **`runCommand()`**: Executes shell processes (flutter, dart, git) directly within the active project's absolute working directory.
3.  **Strict Isolation**: Every internal `dart:io` call uses `path.join(activePath, ...)` to ensure the CLI remains project-agnostic and never modifies its own installation folder.

---

## 🤝 CONTRIBUTING & QUALITY STANDARDS
The Tronixbyte CLI follows strict quality standards. To contribute:
1. Ensure your code passes the built-in quality gate: `tools quality`.
2. All new utilities must be context-aware (using `activePath`).
3. Document new features in the corresponding `z_*.dart` barrels.
4. Maintain the workstation-level abstraction—never assume `Directory.current`.

---
*Developed by **Tronixbyte Engineering** for the next generation of Flutter engineers who build scalable, secure, and high-performance applications.*
