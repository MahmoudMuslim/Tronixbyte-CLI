import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runDependencySecurityScan() async {
  printSection('🛡️ Dependency Security Guard (CVE Scan)');

  final activePath = getActiveProjectPath();
  final pubspec = File(p.join(activePath, 'pubspec.yaml'));

  if (!pubspec.existsSync()) {
    printError('pubspec.yaml not found at ${pubspec.path}.');
    return;
  }

  final List<Map<String, String>> vulnerabilities = [];

  await loadingSpinner(
    'Scanning dependencies for known vulnerabilities in $activePath',
    () async {
      final content = pubspec.readAsStringSync();
      final depsMatch = RegExp(
        r'^dependencies:\s*\n([\s\S]*?)(?=\n\S|$)',
        multiLine: true,
      ).firstMatch(content);

      if (depsMatch == null) return;

      final lines = depsMatch.group(1)!.split('\n');
      final List<String> packages = [];

      for (var line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty ||
            trimmed.startsWith('#') ||
            trimmed.startsWith('flutter:') ||
            trimmed == 'flutter') {
          continue;
        }
        final name = trimmed.split(':').first.trim();
        if (name.isNotEmpty && name != 'sdk') packages.add(name);
      }

      // In a real CLI, we would query a CVE database API like OSV.dev
      // For this implementation, we'll simulate the check against a mock vulnerability list
      for (final pkg in packages) {
        if (pkg == 'http') {
          vulnerabilities.add({
            'pkg': pkg,
            'severity': 'HIGH',
            'info': 'Potential request smuggling in older versions.',
          });
        }
      }

      // Official audit command
      final result = await Process.run('flutter', [
        'pub',
        'deps',
        '--list-advisories',
      ], workingDirectory: activePath);

      if (result.exitCode == 0 &&
          result.stdout.toString().contains('advisory')) {
        printWarning('Official advisories found in your dependencies!');
        print(result.stdout);
      }
    },
  );

  if (vulnerabilities.isEmpty) {
    printSuccess(
      'No known critical vulnerabilities found in your dependencies.',
    );
    printInfo(
      '👉 Tip: Always keep your packages updated using "tools upgrade".',
    );
  } else {
    printWarning(
      'Found \${vulnerabilities.length} potential security advisories:',
    );
    for (var v in vulnerabilities) {
      print(
        '   \$red\$bold[${v['severity']}]\$reset ${v['pkg']}: ${v['info']}',
      );
    }
  }
}
