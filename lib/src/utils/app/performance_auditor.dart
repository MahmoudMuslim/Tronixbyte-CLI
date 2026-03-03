import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runPerformanceAudit() async {
  printSection('Performance & Size Auditor');

  int issues = 0;
  final List<String> details = [];

  await loadingSpinner('Scanning assets and source code for bottlenecks', () async {
    // 1. Large Image Audit
    final assetsDir = Directory('assets');
    if (assetsDir.existsSync()) {
      final images = assetsDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) {
            final ext = p.extension(f.path).toLowerCase();
            return ['.png', '.jpg', '.jpeg', '.webp'].contains(ext);
          });

      for (final image in images) {
        final size = image.lengthSync();
        if (size > 1024 * 1024) {
          // > 1MB
          details.add(
            '$red$bold[Size]$reset Large image: ${p.relative(image.path)} (${(size / (1024 * 1024)).toStringAsFixed(2)} MB)',
          );
          issues++;
        }
      }
    }

    // 2. Heavy Dependency Check
    final pubspec = File('pubspec.yaml');
    if (pubspec.existsSync()) {
      final content = pubspec.readAsStringSync();
      if (content.contains('flutter_launcher_icons:')) {
        final lines = content.split('\n');
        bool inDevDeps = false;
        for (final line in lines) {
          if (line.trim().startsWith('dev_dependencies:')) inDevDeps = true;
          if (line.trim().startsWith('flutter_launcher_icons:') && !inDevDeps) {
            details.add(
              '$yellow$bold[Dependency]$reset "flutter_launcher_icons" should be in dev_dependencies.',
            );
            issues++;
          }
        }
      }
    }

    // 3. Font Size Check
    final fontsDir = Directory('assets/fonts');
    if (fontsDir.existsSync()) {
      final fonts = fontsDir.listSync().whereType<File>();
      for (final font in fonts) {
        if (font.lengthSync() > 500 * 1024) {
          // > 500KB
          details.add(
            '$cyan$bold[Font]$reset Heavy font file: ${p.relative(font.path)} (${(font.lengthSync() / 1024).toStringAsFixed(0)} KB)',
          );
        }
      }
    }
  });

  if (details.isNotEmpty) {
    print('\n$blue${bold}PERFORMANCE FINDINGS:$reset');
    for (final detail in details) {
      print('   $detail');
    }
  }

  print('\n$blue$bold${'=' * 60}$reset');
  if (issues == 0) {
    printSuccess('Performance audit complete. No major bottlenecks detected!');
  } else {
    printWarning('Audit finished with $issues potential bottlenecks.');
    printInfo(
      '👉 Tip: Use "flutter build apk --analyze-size" for a deeper breakdown.',
    );
  }
}
