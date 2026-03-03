import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

class PerformanceProfile {
  final String name;
  final double targetFps;
  final int jankThresholdMs;

  PerformanceProfile({
    required this.name,
    required this.targetFps,
    required this.jankThresholdMs,
  });
}

Future<void> runDevicePerformanceAudit() async {
  printSection('📊 Device-Specific Performance Auditor');

  final activePath = getActiveProjectPath();
  final featuresDir = Directory(p.join(activePath, 'lib', 'features'));

  if (!featuresDir.existsSync()) {
    printError('lib/features directory not found at ${featuresDir.path}');
    return;
  }

  final profiles = [
    PerformanceProfile(
      name: 'Low-End (60Hz)',
      targetFps: 60,
      jankThresholdMs: 16,
    ),
    PerformanceProfile(
      name: 'Mid-Range (90Hz)',
      targetFps: 90,
      jankThresholdMs: 11,
    ),
    PerformanceProfile(
      name: 'High-End (120Hz ProMotion)',
      targetFps: 120,
      jankThresholdMs: 8,
    ),
  ];

  final screenFiles = featuresDir
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (f) =>
            f.path.contains('presentation/screens') && f.path.endsWith('.dart'),
      )
      .toList();

  if (screenFiles.isEmpty) {
    printInfo('No screens found to audit in the active project.');
    return;
  }

  final screenOptions = screenFiles
      .map((f) => p.basenameWithoutExtension(f.path))
      .toList();
  final choice = selectOption(
    'Select Screen to Audit',
    screenOptions,
    showBack: true,
  );
  if (choice == 'back' || choice == null) return;

  final selectedScreen = screenOptions[int.parse(choice) - 1];
  final List<List<String>> results = [];
  int complexWidgets = 0;

  await loadingSpinner(
    'Simulating UI performance for $selectedScreen',
    () async {
      // Analysis based on file complexity as a proxy for render cost
      final content = screenFiles[int.parse(choice) - 1].readAsStringSync();
      final widgetCount = RegExp(r'Widget').allMatches(content).length;
      complexWidgets = RegExp(
        r'ListView|Stack|Opacity|ClipRRect',
      ).allMatches(content).length;

      for (final profile in profiles) {
        final baseLoad = (widgetCount * 0.1) + (complexWidgets * 0.5);
        final estimatedMs = baseLoad * (profile.targetFps / 60);
        final isJank = estimatedMs > profile.jankThresholdMs;

        results.add([
          profile.name,
          '${estimatedMs.toStringAsFixed(1)}ms',
          '${profile.targetFps.toInt()} FPS',
          isJank ? '🔴 Jank Risk' : '🟢 Smooth',
        ]);
      }
    },
  );

  print('\n$blue$bold🚀 UI PERFORMANCE PROJECTION: $selectedScreen$reset');
  printTable(['Profile', 'Frame Time', 'Target', 'Status'], results);

  print('\n$cyan$bold💡 OPTIMIZATION TIP$reset');
  print(
    '   - Found $complexWidgets expensive widgets. Consider RepaintBoundaries or CustomPainters for better isolation.',
  );

  ask('Press Enter to return');
}
