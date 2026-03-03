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
- **Live Security Vulnerability Feed**: Persistent background integration with **OSV.dev** and **GitHub Advisory Database** for real-time security alerts.
- **License Compliance Guard**: Audits the dependency tree for GPL/AGPL violations to ensure enterprise compliance.

### 🧪 3. ADVANCED TESTING & QUALITY ASSURANCE
*released with 100% confidence through automated verification suites.*

- **Smart Mock Architect**: Crawls your architecture and generates **Mocktail** mocks for all Repositories and DataSources found in your feature folders.
- **"Ghost" Integration Test Recorder**: Captures user flows and generates high-fidelity integration test scaffolding starting from `app.main()`.
- **Visual Assertion Engine**: Automated extraction of on-screen Text and Resource IDs via **ADB shell uiautomator dump** to generate `expect` statements.
- **Cross-Device Playback Matrix**: Sequential playback of integration tests across ALL connected ADB devices with a final summary report.
- **Golden Test Designer**: Infrastructure setup for visual regression testing using **Alchemist**.
- **Coverage Heatmap**: Provides a high-visibility ASCII heatmap of test coverage density across all features.
- **Global Quality Gate**: Single command (`tools quality`) to format, fix, analyze, and test your entire project.

### 🌍 4. ASSETS & LOCALIZATION INTELLIGENCE
*Remove the manual labor from your asset and translation pipelines. Go global in minutes.*

- **AI Translator**: Uses **Google Gemini Pro** to translate your `en.json` into any target language instantly while preserving JSON keys and placeholders.
- **L10n Sync Tool**: Automatically synchronizes missing keys from your master language file to all other locales.
- **Smart Asset Optimizer**: Batch converts and optimizes images (PNG/JPG to WebP) with detailed reports.
- **Multi-Density Bundler**: Automatically generates `2.0x` and `3.0x` density variants for all your assets.
- **Asset Constants Generator**: Scans your `assets/` folder and generates a type-safe `AppAssets` class.

### 📦 5. DEVOPS, DELIVERY & STORE AUTOMATION
*Automate the journey from your workstation to the App Stores.*

- **Enterprise Whitelabeling System**: Supports multi-brand management and atomic swapping of logos and configurations.
- **Dynamic Flavor Code-Gen**: Automates `main_*.dart` and `FlavorConfig` generation based on `flavors.yaml`.
- **CI/CD Wizard**: Scaffolds professional GitHub Actions workflows for Quality Gates, Web Deploy, Shorebird, and Full Releases.
- **Shorebird Manager**: Full lifecycle control for **Shorebird Code Push** (Initialization, Login, Patch, and Release tracking).
- **Monorepo Manager**: Specialized tools for multi-package projects using **Melos**, including dependency graphing.
- **Fastlane Metadata Auditor**: Verifies Play Store and App Store metadata compliance.
- **Multi-Build Hub**: Generate APK, AAB, IPA, and Web release bundles simultaneously.

### 📈 6. ANALYTICS & AUTONOMOUS ENGINEERING
*Real-time insights and self-healing capabilities for modern codebases.*

- **Self-Healing Code Engine**: Uses **Gemini Pro 1.5** to automatically fix lint warnings and errors detected by `flutter analyze`.
- **Dynamic Widget Catalog (Gallery)**: Automatically crawls shared widgets and scaffolds a Storybook-style Gallery module.
- **Visual Technical Debt Monitor**: Provides a project-wide "Architectural Health Score" based on LOC, complexity, and coverage.
- **Automated Feature Documentation**: Scans UseCases, Entities, and Screens to create per-feature technical READMEs automatically.
- **Project Doctor**: Deep health diagnosis of project structure, mandatory files, and environment synchronization.
- **Growth & Velocity Predictor**: Predictive modeling of project scale and release dates based on historical Git data.

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

| Tier | Standard / Technology | Recommendation |
| :--- | :--- | :--- |
| **Language** | Dart 3.x | Patterns, Records, and Null-Safety. |
| **Framework** | Flutter 3.x | Skia/Impeller, Desktop, Web, Mobile. |
| **State** | Modular managers | BLoC, Riverpod, GetX, Provider. |
| **Navigation** | Type-safe routing | GoRouter Builder with absolute paths. |
| **Networking** | Functional API | Dio, Retrofit, Dartz (Functional). |
| **Persistence** | Type-safe DB | Drift (SQLite), Secure Storage. |
| **Intelligence** | Generative AI | Google Gemini Pro 1.5. |
| **Delivery** | CI/CD | GitHub Actions, Fastlane, Shorebird. |

---

## 🗺️ PROJECT ELITE ROADMAP

### 🏆 Completed Excellence (Phase 23, 24 & 25)
*Status: Production Ready & Globally Deployed*

| 🚀 Milestone | 🛰️ Status | 📊 Progress |
| :--- | :---: | :--- |
| **AI Architect Mode (Blueprinting & Synthesis)** | ✅ | [████████████████████] 100% |
| **"Ghost" Integration Test Suite (ADB & Matrix)** | ✅ | [████████████████████] 100% |
| **Autonomous Engineering (Self-Healing & Gallery)** | ✅ | [████████████████████] 100% |
| **Strategic Hardening (Obfuscation & Secure Enclave)**| ✅ | [████████████████████] 100% |
| **Enterprise Orchestration (Whitelabel & Flavors)** | ✅ | [████████████████████] 100% |
| **Advanced Static Auditing (Leaks, Boundaries, Dead Code)**| ✅ | [████████████████████] 100% |
| **Live Security Feed & License Guard** | ✅ | [████████████████████] 100% |
| **Automated Feature Documentation** | ✅ | [████████████████████] 100% |

### ⚡ NEXT FRONTIER: Phase 26 - Infrastructure & Predictive Intelligence
*Status: Active Research & Planning*

| 🛠️ Task | 📡 Status | 📈 Progress |
| :--- | :---: | :--- |
| **Multi-Tenant Cloud Scaffolder (Infra-as-Code)** | 🚧 | [██████░░░░░░░░░░░░░░] 30% |
| **Edge Function Logic Templates (Dart/TS)** | 🚧 | [████░░░░░░░░░░░░░░░░] 20% |
| **Predictive Performance Profiler (Frame-Drop)** | 🚧 | [██░░░░░░░░░░░░░░░░░░] 10% |
| **Automated Test Repair (AI-Driven Healing)** | ⏳ | [░░░░░░░░░░░░░░░░░░░░] 0% |
| **Bundle Size Budgeting & Real-Time Tracking** | ⏳ | [░░░░░░░░░░░░░░░░░░░░] 0% |

---

## 🏛️ SYSTEM ARCHITECTURE & INTERNALS
The toolkit is designed as a **Universal Dart Binary**, optimized for high-performance workstation execution.

### Absolute Path Resolution Engine
The core of the toolkit's project-agnosticism lies in its absolute path engine.
1.  **Context Detection**: Uses `.tronix_history.json` to identify the current target project and its root.
2.  **Working Directory**: The `runCommand()` utility executes shell processes (flutter, dart, git) directly within the target project's absolute working directory.
3.  **Strict Isolation**: Every internal `dart:io` call uses `path.join(activePath, ...)` to ensure the CLI remains project-agnostic and never modifies its own installation folder.

---

## 🛠️ INSTALLATION & SETUP

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

## 🤝 CONTRIBUTING & STANDARDS
The Tronixbyte CLI follows strict quality standards. To contribute:
1. Ensure your code passes the built-in quality gate: `tools quality`.
2. All new utilities must be context-aware (using `activePath` via `getActiveProjectPath()`).
3. Document new features in the corresponding `z_*.dart` barrels for clean exports.

---

## 🛡️ LICENSE
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
*Developed by **Tronixbyte Engineering** for the next generation of Flutter engineers who build scalable, secure, and high-performance applications.*
