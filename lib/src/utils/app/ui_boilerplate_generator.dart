import 'package:tools/tools.dart';

Future<void> generateSharedUiBoilerplate() async {
  printSection('Shared UI Boilerplate Generator');

  final projectName = await getProjectName();
  final widgetDir = Directory('lib/shared/widgets');
  if (!widgetDir.existsSync()) widgetDir.createSync(recursive: true);

  final widgets = {
    'app_button.dart': getAppButtonTemplate(projectName),
    'app_dialogs.dart': getAppDialogsTemplate(projectName),
    'app_image.dart': getAppImageTemplate(projectName),
    'app_text_field.dart': getAppTextFieldTemplate(projectName),
    'app_shimmer.dart': getAppShimmerTemplate(projectName),
    'app_card.dart': getAppCardTemplate(projectName),
    'app_list_tile.dart': getAppListTileTemplate(projectName),
    'app_divider.dart': getAppDividerTemplate(projectName),
    'empty_view.dart': getEmptyViewTemplate(projectName),
    'error_view.dart': getErrorViewTemplate(projectName),
  };

  await loadingSpinner('Generating elite shared widgets', () async {
    widgets.forEach((name, content) {
      final file = File('lib/shared/widgets/$name');
      file.writeAsStringSync(content);
      printInfo('Generated: lib/shared/widgets/$name');
    });

    // Update Barrel
    final barrelFile = File('lib/shared/widgets/z_widgets.dart');
    if (!barrelFile.existsSync()) {
      barrelFile.writeAsStringSync('');
    }

    final content = barrelFile.readAsStringSync();
    final newExports = widgets.keys
        .where((k) => !content.contains(k))
        .map((k) => "export '$k';")
        .join('\n');

    if (newExports.isNotEmpty) {
      final updatedContent = content.isEmpty
          ? newExports
          : '$content\n$newExports';
      barrelFile.writeAsStringSync('$updatedContent\n');
    }
  });

  printSuccess(
    'Shared UI Boilerplate ready! Use them via "AppButton", "AppTextField", "AppCard", etc.',
  );
}
