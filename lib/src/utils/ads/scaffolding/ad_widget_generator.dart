import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> generateAdWidgets(
  String projectName,
  List<String> enabledTypes,
) async {
  final activePath = getActiveProjectPath();

  await loadingSpinner('Generating interactive Ad Widgets', () async {
    final widgetDir = Directory(
      p.join(activePath, 'lib', 'shared', 'widgets', 'ad_widgets'),
    );
    if (!widgetDir.existsSync()) widgetDir.createSync(recursive: true);

    if (enabledTypes.contains('adaptive_banner') ||
        enabledTypes.contains('fixed_banner')) {
      final bannerFile = File(p.join(widgetDir.path, 'app_banner_ad.dart'));
      bannerFile.writeAsStringSync(getAppBannerAdTemplate(projectName));
    }

    // Update Barrel
    final barrelFile = File(p.join(widgetDir.path, 'z_ad_widgets.dart'));
    final exports = widgetDir
        .listSync()
        .whereType<File>()
        .where((f) => !p.basename(f.path).startsWith('z_'))
        .map((f) => "export '${p.basename(f.path)}';")
        .join('\n');
    barrelFile.writeAsStringSync('$exports\n');

    final sharedBarrel = File(
      p.join(activePath, 'lib', 'shared', 'widgets', 'z_widgets.dart'),
    );
    if (sharedBarrel.existsSync()) {
      String content = sharedBarrel.readAsStringSync();
      if (!content.contains('ad_widgets/z_ad_widgets.dart')) {
        sharedBarrel.writeAsStringSync(
          content.endsWith('\n')
              ? "$content\nexport 'ad_widgets/z_ad_widgets.dart';\n"
              : "$content\n\nexport 'ad_widgets/z_ad_widgets.dart';\n",
        );
      }
    }
  });
}
