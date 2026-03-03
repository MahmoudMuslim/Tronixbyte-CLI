import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runSharedComponentGallery() async {
  printSection('🖼️ Dynamic Widget Catalog (Gallery)');

  final activePath = getActiveProjectPath();
  final projectName = await getProjectName();

  final widgetsDir = Directory(p.join(activePath, 'lib', 'shared', 'widgets'));
  if (!widgetsDir.existsSync()) {
    printWarning('Shared widgets directory not found at lib/shared/widgets.');
    return;
  }

  final widgets = widgetsDir
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (f) => f.path.endsWith('.dart') && !p.basename(f.path).startsWith('z_'),
      )
      .toList();

  if (widgets.isEmpty) {
    printInfo('No shared widgets found to display in gallery.');
    return;
  }

  printInfo(
    'Discovered ${widgets.length} shared widgets. Generating Storybook module...',
  );

  await loadingSpinner('Scaffolding Widget Gallery at lib/gallery/', () async {
    final galleryDir = Directory(p.join(activePath, 'lib', 'gallery'));
    if (!galleryDir.existsSync()) galleryDir.createSync(recursive: true);

    final buffer = StringBuffer();
    buffer.writeln("import 'package:flutter/material.dart';");
    buffer.writeln("import 'package:$projectName/z_src.dart';\n");
    buffer.writeln("class WidgetGallery extends StatelessWidget {");
    buffer.writeln("  const WidgetGallery({super.key});\n");
    buffer.writeln("  @override");
    buffer.writeln("  Widget build(BuildContext context) {");
    buffer.writeln("    return Scaffold(");
    buffer.writeln(
      "      appBar: AppBar(title: const Text('Widget Catalog')),",
    );
    buffer.writeln("      body: ListView(");
    buffer.writeln("        padding: const EdgeInsets.all(16),");
    buffer.writeln("        children: [");

    for (final widget in widgets) {
      final fileName = p.basenameWithoutExtension(widget.path);
      final className = fileName
          .split('_')
          .map((s) => s[0].toUpperCase() + s.substring(1))
          .join();

      buffer.writeln(
        "          const Text('$className', style: TextStyle(fontWeight: FontWeight.bold)),",
      );
      buffer.writeln("          const SizedBox(height: 10),");
      buffer.writeln(
        "          const $className(), // Ensure widget has a default const constructor",
      );
      buffer.writeln("          const Divider(height: 40),");
    }

    buffer.writeln("        ],");
    buffer.writeln("      ),");
    buffer.writeln("    );");
    buffer.writeln("  }");
    buffer.writeln("}");

    final galleryFile = File(p.join(galleryDir.path, 'widget_gallery.dart'));
    galleryFile.writeAsStringSync(buffer.toString());
  });

  printSuccess('Widget Gallery scaffolded at lib/gallery/widget_gallery.dart');
  printInfo('👉 Run with your preferred flavor to preview components.');

  ask('Press Enter to return');
}
