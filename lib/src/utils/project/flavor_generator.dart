import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runFlavorGenerator() async {
  printSection('🍦 Dynamic Flavor Code-Gen');

  final activePath = getActiveProjectPath();
  final flavorYaml = File(p.join(activePath, 'flavors.yaml'));

  if (!flavorYaml.existsSync()) {
    printInfo('Creating default flavors.yaml in $activePath...');
    flavorYaml.writeAsStringSync(getFlavorGeneratorTemplate());
    printSuccess('Generated flavors.yaml. Please configure it and run again.');
    return;
  }

  await loadingSpinner(
    'Generating flavor-specific entry points and configurations',
    () async {
      // 1. Read YAML (Simplified parsing)
      final content = flavorYaml.readAsStringSync();
      final flavorRegex = RegExp(
        r'(\w+):\s*\n\s+name:\s+"(.+)"\s*\n\s+api_url:\s+"(.+)"',
      );
      final matches = flavorRegex.allMatches(content);

      final List<String> flavorNames = [];

      // 2. Generate AppFlavor Config
      final configDir = Directory(p.join(activePath, 'lib', 'core', 'config'));
      if (!configDir.existsSync()) configDir.createSync(recursive: true);

      final flavorEnumBuffer = StringBuffer();
      flavorEnumBuffer.writeln('enum AppFlavor { dev, stg, prod }\n');
      flavorEnumBuffer.writeln('class FlavorConfig {');
      flavorEnumBuffer.writeln('  final String name;');
      flavorEnumBuffer.writeln('  final String apiUrl;');
      flavorEnumBuffer.writeln('  final AppFlavor flavor;\n');
      flavorEnumBuffer.writeln('  static late FlavorConfig _instance;');
      flavorEnumBuffer.writeln(
        '  static FlavorConfig get instance => _instance;\n',
      );
      flavorEnumBuffer.writeln(
        '  FlavorConfig({required this.name, required this.apiUrl, required this.flavor});\n',
      );
      flavorEnumBuffer.writeln(
        '  static void initialize({required String name, required String apiUrl, required AppFlavor flavor}) {',
      );
      flavorEnumBuffer.writeln(
        '    _instance = FlavorConfig(name: name, apiUrl: apiUrl, flavor: flavor);',
      );
      flavorEnumBuffer.writeln('  }');
      flavorEnumBuffer.writeln('}');

      File(
        p.join(configDir.path, 'app_flavor.dart'),
      ).writeAsStringSync(flavorEnumBuffer.toString());

      // 3. Generate Entry Points
      for (final match in matches) {
        final flavorKey = match.group(1)!;
        final name = match.group(2)!;
        final apiUrl = match.group(3)!;
        flavorNames.add(flavorKey);

        final mainContent =
            """
import 'package:flutter/material.dart';
import 'package:path/path.dart'; // Example placeholder
import 'core/config/app_flavor.dart';
import 'app.dart';

void main() {
  FlavorConfig.initialize(
    name: "$name",
    apiUrl: "$apiUrl",
    flavor: AppFlavor.$flavorKey,
  );
  runApp(const App());
}
""";
        File(
          p.join(activePath, 'lib', 'main_$flavorKey.dart'),
        ).writeAsStringSync(mainContent.trim());
      }
    },
  );

  printSuccess('Flavor generation complete for the active project!');
  printInfo('👉 Entry points generated: lib/main_*.dart');
  printInfo('👉 Config generated: lib/core/config/app_flavor.dart');

  ask('Press Enter to return');
}
