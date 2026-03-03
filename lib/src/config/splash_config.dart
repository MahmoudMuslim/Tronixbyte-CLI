import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> configureNativeSplash() async {
  printSection('Native Splash Configuration');
  final activePath = getActiveProjectPath();
  final fnsSb = StringBuffer();

  final color = ask('Background Color (e.g., "#ffffff")');
  if (color != null) {
    addField(fnsSb, 'color', color);
    addField(fnsSb, 'image', ask('Splash Image Path'));
    addField(fnsSb, 'branding', ask('Branding Image Path'));
    addField(fnsSb, 'branding_bottom_padding', ask('Branding Bottom Padding'));
    addField(fnsSb, 'color_dark', ask('Dark Background Color'));
    addField(fnsSb, 'image_dark', ask('Dark Splash Image Path'));
    addField(fnsSb, 'branding_dark', ask('Dark Branding Image Path'));

    final a12Image = ask('Android 12 Image Path');
    if (a12Image != null) {
      fnsSb.writeln('android_12:');
      addField(fnsSb, 'image', a12Image, 1);
      addField(
        fnsSb,
        'icon_background_color',
        ask('Android 12 Icon BG Color'),
        1,
      );
      addField(fnsSb, 'image_dark', ask('Android 12 Dark Image Path'), 1);
      addField(
        fnsSb,
        'icon_background_color_dark',
        ask('Android 12 Dark Icon BG Color'),
        1,
      );
    }

    await loadingSpinner('Generating splash screen configurations', () async {
      final configFile = File(p.join(activePath, 'flutter_native_splash.yaml'));
      configFile.writeAsStringSync(fnsSb.toString());

      printInfo('Running flutter_native_splash:create...');
      await runCommand('dart', ['run', 'flutter_native_splash:create']);
    });

    printSuccess('Native splash screen generated successfully!');
  } else {
    printInfo('No background color provided. Skipping splash configuration.');
  }
}
