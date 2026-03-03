import 'package:tools/tools.dart';

Future<void> configureIconsLauncher() async {
  printSection('App Icon Configuration');

  final ilSb = StringBuffer();
  final platforms = ['android', 'ios', 'web', 'macos', 'windows', 'linux'];

  final globalImagePath = ask(
    'Global Image Path (e.g., assets/ic_logo_radius.png)',
  );
  if (globalImagePath != null) {
    addField(ilSb, 'image_path', globalImagePath);
  }

  ilSb.writeln('platforms:');
  for (final platform in platforms) {
    final enabled = ask('Enable $platform icons? (true/false)');
    if (enabled != null) {
      ilSb.writeln('  $platform:');
      addField(ilSb, 'enable', enabled, 2);

      final overridePath = ask('Image Path override for $platform');
      if (overridePath != null) {
        addField(ilSb, 'image_path', overridePath, 2);
      }

      if (platform == 'android') {
        _addField(
          ilSb,
          'notification_image',
          ask('Android Notification Image'),
          2,
        );
        _addField(
          ilSb,
          'adaptive_background_image',
          ask('Adaptive Background Image'),
          2,
        );
        _addField(
          ilSb,
          'adaptive_foreground_image',
          ask('Adaptive Foreground Image'),
          2,
        );
        _addField(ilSb, 'adaptive_round_image', ask('Adaptive Round Image'), 2);
        _addField(
          ilSb,
          'adaptive_monochrome_image',
          ask('Adaptive Monochrome Image'),
          2,
        );
      }

      if (platform == 'ios') {
        _addField(ilSb, 'dark_path', ask('Dark Path (iOS 18+)'), 2);
        _addField(ilSb, 'tinted_path', ask('Tinted Path (iOS 18+)'), 2);
      }

      if (platform == 'web') {
        _addField(ilSb, 'favicon_path', ask('Favicon Path'), 2);
      }
    }
  }

  if (ilSb.isNotEmpty) {
    await loadingSpinner(
      'Generating icon configurations and creating assets',
      () async {
        final file = File('icons_launcher.yaml');
        file.writeAsStringSync(ilSb.toString());

        printInfo('Running icons_launcher:create...');
        await runCommand('dart', ['run', 'icons_launcher:create']);
      },
    );

    printSuccess(
      'App icons generated successfully across all enabled platforms!',
    );
  } else {
    printInfo('No platforms enabled. Skipping icon generation.');
  }
}

void _addField(StringBuffer sb, String key, String? value, [int indent = 0]) {
  if (value != null && value.isNotEmpty) {
    sb.writeln('${'  ' * indent}$key: $value');
  }
}
