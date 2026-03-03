# ⚡ Tronixbyte Elite CLI Toolkit

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

The **Tronixbyte CLI** is an enterprise-grade, project-agnostic toolkit designed to automate, manage, and accelerate Flutter development system-wide. It enforces **Clean Architecture**, ensures production readiness, and handles complex maintenance tasks from a single global command.

---

## 🌎 Global Project Context & Workflow
The Tronixbyte CLI is a workstation-level utility. It is not tied to any single project directory.

- **Persistent Active Project**: The CLI tracks your "Active Project" globally. Once a project is selected (via `Manage Existing Project` or `tools sync`), the CLI remembers it. All future commands automatically target that project's absolute path.
- **Project History**: Built-in manager to switch contexts between recently created or managed projects instantly.
- **Smart Path Resolution**: Internally uses absolute paths, ensuring that commands run from anywhere correctly target your app's root without modifying the CLI source.
- **Terminal Independence**: Run `tools` from your desktop, your project folder, or a global terminal window—it always knows which app you're building.

---

## 🚀 Modules & Comprehensive Capabilities

### 🏗️ 1. Project Scaffolding & Initiation
Standardize your project starts with elite configurations.
- **Flutter Create Elite**: A specialized wizard that sets up projects with enterprise standards (custom org, description, specific platforms, and clean templates).
- **Dart Scaffolder**: Rapidly bootstrap CLI tools, Console apps, or Server-side (Shelf) projects.
- **Auto-Handover**: Newly created projects are immediately set as the global active context.

### 🏛️ 2. Clean Architecture & Maintenance
Enforce a rock-solid, scalable foundation automatically.
- **Elite Feature Scaffolder**: Generates modular features with isolated layers (`Data`, `Domain`, `Presentation`).
  - **Logic Types**: `bloc`, `cubit`, `riverpod`, `getx`, `provider`.
- **Recursive Barrel Synchronizer**: Automatically creates and updates `z_*.dart` export files.
- **Smart Injection Wiring**: Automated registration of features, repositories, and services in `lib/injection.dart` using `GetIt`.
- **UI Boilerplate Generator**: Scaffolds a set of elite, reusable components (`AppButton`, `AppTextField`, `AppImage`, `AppShimmer`, etc.).
- **Architecture Mapper**: Visualizes feature dependencies via **Mermaid.js** diagrams.
- **Architecture Linter**: Enforces strict layer boundaries (e.g., Domain must remain pure).
- **Naming Convention Enforcer**: Ensures files (`snake_case`) and classes (`PascalCase`) follow industry standards.

### 🛡️ 3. Security, Hardening & Compliance
Professional-grade security tools to protect your users and data.
- **Deep Security Auditor**: Scans code for OWASP violations, insecure storage (SharedPreferences for tokens), and cleartext traffic.
- **Hardcoded Secret Extractor**: Detects sensitive strings and automatically migrates them to `.env` files, refactoring your code to use `flutter_dotenv`.
- **Security Scaffolding**: 
  - **SSL Pinning**: Scaffold Dio interceptors for certificate fingerprint verification.
  - **Biometric Auth**: FaceID/TouchID service implementation using `local_auth`.
  - **Jailbreak/Root Detection**: Scaffolds device integrity verification logic.
- **Penetration Tester**: Simulates basic payload fuzzing and header injection attacks.
- **Dependency Security Guard**: Scans `pubspec.lock` against CVE databases (OSV.dev).

### 🧪 4. Advanced Testing & QA
High-velocity testing automation for high-confidence releases.
- **Smart Mock Architect**: Generates **Mocktail** mocks for all Repositories and DataSources.
- **Widget Test Generator**: Scaffolds widget tests for every screen found in your features.
- **Golden Test Designer**: Infrastructure setup for visual regression testing using **Alchemist**.
- **Coverage Heatmap**: High-visibility ASCII heatmap of test coverage density across all features.
- **Screenshot Automator & Comparator**: Captures app screenshots across device sizes and performs pixel-match comparisons to detect visual regressions.

### 🌍 5. Assets & Localization Intelligence
Remove the manual labor from your asset and translation pipelines.
- **AI Translator**: Uses **Google Gemini AI** to translate your `en.json` into any target language instantly.
- **L10n Sync & Validator**: Synchronizes missing keys across locales and validates translation integrity.
- **Smart Asset Optimizer**: Batch conversion of PNG/JPG to WebP and multi-density (`2.0x`, `3.0x`) bundling.
- **Asset Constants Generator**: Generates type-safe `AppAssets` referencing for all files.

### 📦 6. DevOps, Delivery & Monorepo
Automate the journey from your workstation to the App Stores.
- **CI/CD Wizard**: Scaffolds GitHub Actions for Quality Gates, Web Deploy, Shorebird, and Releases.
- **Shorebird Manager**: Full control for **Shorebird Code Push** (Install, Patch, Release).
- **Monorepo Manager**: Specialized tools for **Melos** workspaces, including dependency graphing and version syncing.
- **Fastlane Metadata Auditor**: Verifies store compliance for metadata (titles, descriptions, screenshots).
- **Multi-Build Release Hub**: Generate APK, AAB, IPA, and Web release bundles in one pass.

### 📈 7. Project Analytics & scaling
- **Project Doctor**: Deep health diagnosis of structure, files, dependencies, and environment sync.
- **Growth Forecaster**: Predictive modeling of project scale (LOC and Assets) based on history.
- **Velocity Predictor**: Git-based analysis of development momentum and release dates.
- **Code Metrics Dashboard**: Detailed breakdown of Business Logic vs UI code ratios.
- **Behavioral Analytics Auditor**: Scans for event tracking coverage across features.

---

## 🛠️ Installation & Setup

1. **Clone the Repository**:
   ```sh
   git clone https://github.com/tronixbyte/tools.git
   cd tools
   dart pub get
   ```

2. **Compile to Standalone EXE**:
   ```sh
   dart compile exe bin/tools.dart -o tools.exe
   ```

3. **Configure Global Access**:
   - **Windows**: Add the folder containing `tools.exe` to your **User Path** environment variable.
   - **macOS/Linux**: `mv tools.exe /usr/local/bin/tools` or create an alias in your shell config.

---

## 💻 Operational Shortcuts Reference
Run these from any directory to manage your **Active Project**:

| Shortcut | Description |
| :--- | :--- |
| `tools <name> <type>` | Fast scaffold: `tools profile bloc` |
| `tools sync` | Deep synchronization: Barrels, code-gen, and L10n |
| `tools repair` | Nuclear repair: Re-links barrels, injections, and assets |
| `tools doctor` | Diagnoses structural health and missing config files |
| `tools audit` | Full security, performance, and leak audit |
| `tools quality` | Single-command Quality Gate (Format, Fix, Analyze, Test) |
| `tools stats` | Real-time project complexity and metrics dashboard |
| `tools clean` | Deep clean project and refresh all dependencies |
| `tools help` | Show detailed command documentation |

---

## 🏗️ Technical Stack Support
- **Architecture**: Strict Clean Architecture (Domain, Data, Presentation).
- **State Management**: BLoC, Cubit, Riverpod, GetX, Provider.
- **Navigation**: Type-safe GoRouter Builder.
- **Database**: Drift (SQLite).
- **Network**: Dio + Retrofit + Dartz (Functional Error Handling).
- **AI Engine**: Google Gemini AI.

---
*Developed by **Tronixbyte** for engineers who demand high-velocity execution without compromising architectural integrity.*
