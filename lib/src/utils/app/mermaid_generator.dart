import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> generateProjectDashboard() async {
  printSection('Project Dashboard Generator');

  final projectName = await getProjectName();

  await loadingSpinner(
    'Generating Elite Project Dashboard (Mermaid Diagram)',
    () async {
      final buffer = StringBuffer();
      buffer.writeln('# 🏗️ Project Architecture Dashboard: $projectName\n');
      buffer.writeln('Generated on: ${DateTime.now().toIso8601String()}\n');

      buffer.writeln('## 🗺️ High-Level Architectural Map');
      buffer.writeln('```mermaid');
      buffer.writeln('graph TD');
      buffer.writeln('    subgraph App_Entry ["🚀 Application Entry"]');
      buffer.writeln('        Main["main.dart"]');
      buffer.writeln('        App["app.dart"]');
      buffer.writeln('        Injection["injection.dart"]');
      buffer.writeln('    end');

      buffer.writeln(
        '\n    subgraph Core_Layer ["🛡️ Core Layer (Shared Logic)"]',
      );
      buffer.writeln('        Theme["Theme (BLoC/Cubit)"]');
      buffer.writeln('        Locale["Locale (BLoC/Cubit)"]');
      buffer.writeln('        Database["Database (Drift)"]');
      buffer.writeln('        Api["API (Dio/Retrofit)"]');
      buffer.writeln('        Utils["Utils & Extensions"]');
      buffer.writeln('    end');

      final featuresDir = Directory('lib/features');
      final List<String> featureNames = [];
      final List<String> dependencies = [];

      if (featuresDir.existsSync()) {
        buffer.writeln(
          '\n    subgraph Features_Layer ["📦 Features (Modules)"]',
        );
        final features = featuresDir.listSync().whereType<Directory>().toList();
        features.sort(
          (a, b) => p.basename(a.path).compareTo(p.basename(b.path)),
        );

        for (final feature in features) {
          final name = p.basename(feature.path);
          if (name.startsWith('z_')) continue;
          featureNames.add(name);
          final namePascal = name[0].toUpperCase() + name.substring(1);
          buffer.writeln('        $name["$namePascal Feature"]');

          // Scan for cross-feature dependencies
          final files = feature
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'));
          for (final file in files) {
            final content = file.readAsStringSync();
            for (final other in features) {
              final otherName = p.basename(other.path);
              if (otherName == name || otherName.startsWith('z_')) continue;
              if (content.contains('/features/$otherName/')) {
                dependencies.add('    $name -.-> $otherName');
              }
            }
          }
        }
        buffer.writeln('    end');
      }

      buffer.writeln('\n    %% Framework Relationships');
      buffer.writeln('    Main --> App');
      buffer.writeln('    App --> Injection');
      buffer.writeln('    App --> Core_Layer');
      buffer.writeln('    App --> Features_Layer');
      buffer.writeln('    Features_Layer --> Core_Layer');

      if (dependencies.isNotEmpty) {
        buffer.writeln('\n    %% Cross-Feature Dependencies');
        buffer.writeln(dependencies.toSet().join('\n'));
      }

      buffer.writeln('```\n');

      buffer.writeln('## 📦 Project Complexity Metrics');
      final libDir = Directory('lib');
      if (libDir.existsSync()) {
        int totalFiles = 0;
        int totalLines = 0;

        final entities = libDir.listSync(recursive: true);
        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.dart')) {
            totalFiles++;
            totalLines += entity.readAsLinesSync().length;
          }
        }
        buffer.writeln('| Metric | Value |');
        buffer.writeln('| :--- | :--- |');
        buffer.writeln('| Total Features | ${featureNames.length} |');
        buffer.writeln('| Total Dart Files | $totalFiles |');
        buffer.writeln('| Total Lines of Code | $totalLines |');
        buffer.writeln(
          '| Avg. Lines per File | ${(totalLines / totalFiles).toStringAsFixed(1)} |',
        );
      }

      buffer.writeln('\n## 🛠️ Feature Breakdown');
      buffer.writeln('| Feature | Layers | Dependencies | Status |');
      buffer.writeln('| :--- | :--- | :---: | :---: |');

      for (final name in featureNames) {
        final layers = [];
        final featPath = 'lib/features/$name';
        if (Directory('$featPath/domain').existsSync()) layers.add('Domain');
        if (Directory('$featPath/data').existsSync()) layers.add('Data');
        if (Directory('$featPath/presentation').existsSync()) layers.add('UI');

        final depCount = dependencies
            .where((d) => d.startsWith('    $name '))
            .length;
        final status = depCount > 0 ? '⚠️ Coupled' : '✅ Modular';

        buffer.writeln(
          '| **${name.toUpperCase()}** | ${layers.join(', ')} | $depCount | $status |',
        );
      }

      buffer.writeln('\n## 🚀 CLI Maintenance Guide');
      buffer.writeln('| Command | Purpose |');
      buffer.writeln('| :--- | :--- |');
      buffer.writeln(
        '| `dart bin/tools.dart sync` | Dependency & Code-gen Sync |',
      );
      buffer.writeln(
        '| `dart bin/tools.dart repair` | Nuclear Infrastructure Fix |',
      );
      buffer.writeln(
        '| `dart bin/tools.dart doctor` | Architecture & Health Check |',
      );

      buffer.writeln('\n---');
      buffer.writeln('*Generated by ⚡ Tronixbyte CLI*');

      File('STRUCTURE.md').writeAsStringSync(buffer.toString());
    },
  );

  printSuccess('Generated: STRUCTURE.md');
}
