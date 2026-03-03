import 'package:tools/tools.dart';

Future<void> generateSharedWidget() async {
  printSection('Shared Widget Generator');

  final name = ask('Enter the widget name (e.g., custom_button)');
  if (name == null || name.isEmpty) return;

  final namePascal = name
      .split('_')
      .map((e) => e[0].toUpperCase() + e.substring(1))
      .join();
  final widgetPath = 'lib/shared/widgets/$name.dart';

  if (File(widgetPath).existsSync()) {
    printError('Widget "$name" already exists at $widgetPath');
    return;
  }

  await loadingSpinner('Generating $name widget and updating barrel', () async {
    final template =
        """
import 'package:flutter/material.dart';

class $namePascal extends StatelessWidget {
  const $namePascal({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
""";

    final widgetDir = Directory('lib/shared/widgets');
    if (!widgetDir.existsSync()) {
      widgetDir.createSync(recursive: true);
    }

    File(widgetPath).writeAsStringSync(template);
    printInfo('Generated: $widgetPath');

    // Update barrel file
    final barrelFile = File('lib/shared/widgets/z_widgets.dart');
    final exportLine = "export '$name.dart';\n";

    if (barrelFile.existsSync()) {
      String content = barrelFile.readAsStringSync();
      if (!content.contains(exportLine.trim())) {
        barrelFile.writeAsStringSync(
          content.endsWith('\n')
              ? '$content$exportLine'
              : '$content\n$exportLine',
        );
        printInfo('Updated lib/shared/widgets/z_widgets.dart');
      }
    } else {
      barrelFile.writeAsStringSync(exportLine);
      printInfo('Created lib/shared/widgets/z_widgets.dart');
    }
  });

  printSuccess(
    'Shared widget "$namePascal" created and registered successfully!',
  );
}
