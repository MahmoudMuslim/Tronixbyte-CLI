import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runSecurityAudit() async {
  printSection('Deep Security Audit (OWASP Standards)');

  final activePath = getActiveProjectPath();
  int issues = 0;
  final List<Map<String, dynamic>> hardcodedSecrets = [];
  final List<String> findings = [];

  void reportIssue(
    String severity,
    String message, {
    Map<String, dynamic>? data,
  }) {
    String color = severity == 'CRITICAL'
        ? red
        : (severity == 'WARNING' ? yellow : cyan);
    print('   $color$bold[$severity]$reset $message');
    findings.add('[$severity] $message');
    issues++;
    if (data != null) hardcodedSecrets.add(data);
  }

  await loadingSpinner('Performing deep security scan in $activePath', () async {
    // 1. .env in .gitignore
    final gitignore = File(p.join(activePath, '.gitignore'));
    if (gitignore.existsSync()) {
      final content = gitignore.readAsStringSync();
      if (!content.contains('.env')) {
        reportIssue('CRITICAL', '.env files are NOT ignored in .gitignore!');
      }
    }

    // 2. Hardcoded secrets
    final secretRegex = RegExp(
      r'''(password|secret|api[_-]?key|token|auth|key|credential|pwd)\s*[:=]\s*["']([a-zA-Z0-9_\-\.\@]{10,})["']''',
      caseSensitive: false,
    );

    final libDir = Directory(p.join(activePath, 'lib'));
    if (libDir.existsSync()) {
      final files = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) => f.path.endsWith('.dart') && !f.path.contains('.g.dart'),
          );

      for (final file in files) {
        final lines = file.readAsLinesSync();
        final content = lines.join('\n');

        // Check for hardcoded secrets
        for (int i = 0; i < lines.length; i++) {
          final match = secretRegex.firstMatch(lines[i]);
          if (match != null) {
            final keyHint = match.group(1)!;
            final value = match.group(2)!;
            reportIssue(
              'WARNING',
              'Potential hardcoded secret in ${p.relative(file.path, from: activePath)}:${i + 1}',
              data: {
                'file': file,
                'lineIndex': i,
                'value': value,
                'keyHint': keyHint,
              },
            );
          }
        }

        // 3. Insecure Storage Check (OWASP M2)
        if (content.contains('SharedPreferences')) {
          if (content.toLowerCase().contains('token') ||
              content.toLowerCase().contains('password') ||
              content.toLowerCase().contains('secret')) {
            reportIssue(
              'WARNING',
              'Insecure storage detected in ${p.relative(file.path, from: activePath)}: SharedPreferences used for sensitive data. Use FlutterSecureStorage instead.',
            );
          }
        }

        // 4. SSL Pinning Check (OWASP M3)
        if (content.contains('Dio(') || content.contains('Dio()')) {
          if (!content.contains('CertificateInterceptor') &&
              !content.contains('onHttpClientCreate')) {
            reportIssue(
              'INFO',
              'Network client (Dio) found in ${p.relative(file.path, from: activePath)} without explicit SSL Pinning. Consider implementing Certificate Pinning for production.',
            );
          }
        }
      }
    }

    // 5. Android Cleartext & Proguard (OWASP M7)
    final manifest = File(
      p.join(activePath, 'android/app/src/main/AndroidManifest.xml'),
    );
    if (manifest.existsSync()) {
      final content = manifest.readAsStringSync();
      if (content.contains('android:usesCleartextTraffic="true"')) {
        reportIssue(
          'WARNING',
          'Android allows cleartext traffic (HTTP). Vulnerable to MITM.',
        );
      }
    }

    final proguard = File(p.join(activePath, 'android/app/proguard-rules.pro'));
    if (proguard.existsSync()) {
      final content = proguard.readAsStringSync();
      if (content.contains('-keep class **') && !content.contains('#')) {
        reportIssue(
          'INFO',
          'Proguard rules might be too broad (-keep class **). Ensure you are not over-exposing classes.',
        );
      }
    } else {
      reportIssue(
        'WARNING',
        'Proguard rules file missing (proguard-rules.pro). Production builds should be obfuscated.',
      );
    }
  });

  if (issues == 0) {
    printSuccess('Audit passed! No major security issues found.');
  } else {
    print('\n');
    printWarning('Audit finished with $issues potential security concerns.');

    if (hardcodedSecrets.isNotEmpty) {
      print('\n$cyan$bold🛠️  SECRET EXTRACTION AVAILABLE:$reset');
      final fix =
          (ask('Extract ${hardcodedSecrets.length} secrets to .env? (y/n)') ??
                  'n')
              .toLowerCase() ==
          'y';
      if (fix) {
        await loadingSpinner('Extracting secrets', () async {
          for (final secret in hardcodedSecrets) {
            final File file = secret['file'];
            final int lineIndex = secret['lineIndex'];
            final String value = secret['value'];
            final String keyHint = secret['keyHint'].toUpperCase().replaceAll(
              '-',
              '_',
            );
            final envKey =
                '${keyHint}_${DateTime.now().millisecondsSinceEpoch % 1000}';

            final envFiles = ['.env.dev', '.env.stg', '.env.prod', '.env'];
            for (final envName in envFiles) {
              final envFile = File(p.join(activePath, envName));
              if (envFile.existsSync()) {
                final c = envFile.readAsStringSync();
                envFile.writeAsStringSync(
                  '$c\n$envKey=$value',
                  mode: FileMode.write,
                );
              }
            }

            final lines = file.readAsLinesSync();
            lines[lineIndex] = lines[lineIndex].replaceFirst(
              '"$value"',
              "dotenv.env['$envKey'] ?? ''",
            );
            lines[lineIndex] = lines[lineIndex].replaceFirst(
              "'$value'",
              "dotenv.env['$envKey'] ?? ''",
            );
            if (!lines.any((l) => l.contains('flutter_dotenv.dart'))) {
              lines.insert(
                0,
                "import 'package:flutter_dotenv/flutter_dotenv.dart';",
              );
            }
            file.writeAsStringSync(lines.join('\n'), mode: FileMode.write);
          }
        });
        printSuccess('Secrets extracted and code refactored.');
      }
    }
  }

  // Generate security report file
  if (findings.isNotEmpty) {
    final reportFile = File(p.join(activePath, 'SECURITY_REPORT.md'));
    final buffer = StringBuffer();
    buffer.writeln('# 🛡️ Tronixbyte Security Audit Report');
    buffer.writeln('\nGenerated on: ${DateTime.now()}\n');
    buffer.writeln('## 📊 Summary');
    buffer.writeln('- Total Issues: $issues');
    buffer.writeln('\n## 🔍 Detailed Findings');
    for (var f in findings) {
      buffer.writeln('- $f');
    }
    reportFile.writeAsStringSync(buffer.toString(), mode: FileMode.write);
    printInfo(
      'Full security report generated in active project: SECURITY_REPORT.md',
    );
  }
}
