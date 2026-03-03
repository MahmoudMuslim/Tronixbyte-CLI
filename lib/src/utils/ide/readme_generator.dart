import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> generateReadme() async {
  printSection('README Generator');

  final activePath = getActiveProjectPath();
  final projectName = await getProjectName();

  await loadingSpinner('Crafting enterprise README.md in $activePath', () async {
    final buffer = StringBuffer();
    buffer.writeln('# ⚡ $projectName\n');
    buffer.writeln(
      'A professional, enterprise-grade Flutter application built with the **Tronixbyte CLI** ecosystem.\n',
    );

    buffer.writeln('## 🚀 Highlights');
    buffer.writeln(
      '- **Architecture:** Strict Clean Architecture (Domain, Data, Presentation layers)',
    );
    buffer.writeln(
      '- **State Management:** Choice of BLoC, Cubit, Riverpod, GetX, or Provider',
    );
    buffer.writeln('- **Routing:** Type-safe GoRouter implementation');
    buffer.writeln(
      '- **Storage:** High-performance local persistence with Drift (SQLite)',
    );
    buffer.writeln(
      '- **Network:** Dio + Retrofit with functional error handling (Dartz)',
    );
    buffer.writeln(
      '- **CI/CD:** Automated GitHub Actions for quality gates and releases\n',
    );

    buffer.writeln('## 🏗️ Project Structure');
    buffer.writeln('```');
    buffer.writeln('lib/');
    buffer.writeln(
      '├── core/          # Global shared logic, theme, locale, and services',
    );
    buffer.writeln(
      '├── features/      # Modular business logic (scaffolded via CLI)',
    );
    buffer.writeln('├── shared/        # Reusable UI components and widgets');
    buffer.writeln(
      '├── src/           # Low-level framework exports and global access',
    );
    buffer.writeln('└── injection.dart # Dependency injection root');
    buffer.writeln('```\n');

    buffer.writeln('## 📦 Implemented Modules');
    final featuresDir = Directory(p.join(activePath, 'lib', 'features'));
    if (featuresDir.existsSync()) {
      final features = featuresDir.listSync().whereType<Directory>().toList();
      features.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

      for (final feature in features) {
        final name = p.basename(feature.path);
        if (!name.startsWith('z_')) {
          buffer.writeln(
            '- [x] **${name[0].toUpperCase()}${name.substring(1)}**: Scalable module with full layer separation',
          );
        }
      }
    } else {
      buffer.writeln(
        '*No features generated yet. Use the CLI to start building!*',
      );
    }
    buffer.writeln('');

    buffer.writeln('## 🛠️ Developer Ecosystem');
    buffer.writeln(
      'This project uses the **Tronixbyte CLI** for all management tasks.',
    );

    buffer.writeln('### VS Code Integration');
    buffer.writeln(
      'Press `Ctrl+Shift+B` to access professional project tasks:',
    );
    buffer.writeln(
      '- **Sync Project:** Deep dependency and code-gen synchronization',
    );
    buffer.writeln(
      '- **Project Repair:** Nuclear repair of all architectural links',
    );
    buffer.writeln(
      '- **Security Audit:** Scan for leaks and hardcoded secrets',
    );
    buffer.writeln(
      '- **Code Quality:** Comprehensive format, fix, and test suite\n',
    );

    buffer.writeln('### Command Line Interface');
    buffer.writeln('```sh');
    buffer.writeln('tools  # Access the interactive Tronixbyte menu');
    buffer.writeln('```\n');

    buffer.writeln('## 🌐 Multi-Environment Support');
    buffer.writeln(
      'The project is pre-configured with triple-environment support:',
    );
    buffer.writeln('- `.env.dev`: Development environment (default)');
    buffer.writeln('- `.env.stg`: Staging/QA environment');
    buffer.writeln('- `.env.prod`: Production environment\n');

    buffer.writeln('---');
    buffer.writeln(
      '*Generated with ⚡ [Tronixbyte CLI](https://github.com/tronixbyte)*',
    );

    final outFile = File(p.join(activePath, 'README.md'));
    outFile.writeAsStringSync(buffer.toString());
  });

  printSuccess('README.md has been generated with the latest project status.');
}
