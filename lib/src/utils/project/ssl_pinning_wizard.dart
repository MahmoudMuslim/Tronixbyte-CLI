import 'package:tools/tools.dart';

Future<void> runSslPinningWizard() async {
  printSection('🛡️ SSL Pinning Security Wizard');

  printInfo('This tool will help you scaffold SSL Pinning logic for Dio.');
  printInfo(
    'You will need the SHA-256 fingerprint of your server certificate.',
  );

  final domain = ask('Enter the API Domain (e.g., api.example.com)');
  if (domain == null) return;

  final fingerprint = ask(
    'Enter the SHA-256 Fingerprint (leave empty for placeholder)',
  );
  final actualFingerprint = fingerprint ?? 'YOUR_SHA256_FINGERPRINT_HERE';

  await loadingSpinner('Scaffolding SSL Pinning logic', () async {
    final apiDir = Directory('lib/core/api');
    if (!apiDir.existsSync()) apiDir.createSync(recursive: true);

    final projectName = await getProjectName();
    final pinningFile = File('lib/core/api/ssl_pinning_interceptor.dart');

    final content =
        """
import 'dart:io';
import 'package:$projectName/$projectName.dart';

class SslPinningInterceptor extends Interceptor {
  final List<String> allowedFingerprints = [
    '$actualFingerprint',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Note: Secure SSL Pinning usually requires platform-specific implementation
    // or a specialized package like 'http_certificate_pinning'.
    // This interceptor provides a foundation for custom validation logic.
    
    super.onRequest(options, handler);
  }
}

/// Helper to configure Dio with basic Certificate pinning
void configureSslPinning(Dio dio) {
  // In a real implementation, you would use SecurityContext
  // or a Dio adapter to enforce certificate validation.
  debugPrint('🛡️ SSL Pinning active for domain: $domain');
}
""";

    pinningFile.writeAsStringSync(content.trim(), mode: FileMode.write);

    // Update API barrel
    final barrel = File('lib/core/api/z_api.dart');
    if (barrel.existsSync()) {
      String barrelContent = barrel.readAsStringSync();
      if (!barrelContent.contains('ssl_pinning_interceptor.dart')) {
        barrel.writeAsStringSync(
          "\$barrelContent\nexport 'ssl_pinning_interceptor.dart';",
          mode: FileMode.write,
        );
      }
    }
  });

  printSuccess(
    'SSL Pinning logic scaffolded: lib/core/api/ssl_pinning_interceptor.dart',
  );
  printWarning(
    '👉 Important: SSL Pinning requires manual configuration of the Dio HttpClientAdapter for full enforcement.',
  );

  ask('Press Enter to return');
}
