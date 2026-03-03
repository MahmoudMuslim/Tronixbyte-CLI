import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> generateAdService(
  String projectName,
  List<String> enabledTypes,
  Map<String, Map<String, String>> unitIds,
) async {
  final activePath = getActiveProjectPath();

  await loadingSpinner('Generating lib/core/services/ad_service.dart', () async {
    final serviceDir = Directory(p.join(activePath, 'lib', 'core', 'services'));
    if (!serviceDir.existsSync()) serviceDir.createSync(recursive: true);

    final serviceFile = File(p.join(serviceDir.path, 'ad_service.dart'));
    final buffer = StringBuffer();

    buffer.writeln("import 'package:$projectName/$projectName.dart';");
    buffer.writeln("");
    buffer.writeln("class AdService {");
    buffer.writeln("  static Future<void> init() async {");
    buffer.writeln("    if (kIsWeb) return;");
    buffer.writeln("    ");
    buffer.writeln("    // Initialize UMP SDK for GDPR/IDFA Consent");
    buffer.writeln("    final params = ConsentRequestParameters();");
    buffer.writeln(
      "    ConsentInformation.instance.requestConsentInfoUpdate(params, () async {",
    );
    buffer.writeln(
      "      if (await ConsentInformation.instance.isConsentFormAvailable()) {",
    );
    buffer.writeln(
      "        ConsentForm.loadConsentForm((ConsentForm consentForm) async {",
    );
    buffer.writeln(
      "          final status = await ConsentInformation.instance.getConsentStatus();",
    );
    buffer.writeln("          if (status == ConsentStatus.required) {");
    buffer.writeln("            consentForm.show((formError) {");
    buffer.writeln("              _initializeAds();");
    buffer.writeln("            });");
    buffer.writeln("          } else {");
    buffer.writeln("            _initializeAds();");
    buffer.writeln("          }");
    buffer.writeln("        }, (formError) => _initializeAds());");
    buffer.writeln("      } else {");
    buffer.writeln("        _initializeAds();");
    buffer.writeln("      }");
    buffer.writeln("    }, (formError) => _initializeAds());");
    buffer.writeln("  }");
    buffer.writeln("");
    buffer.writeln("  static void _initializeAds() async {");
    buffer.writeln("    await MobileAds.instance.initialize();");
    buffer.writeln("  }");
    buffer.writeln("");

    for (final type in enabledTypes) {
      final methodName = _toCamelCase(type);
      final androidId = unitIds[type]!['android'];
      final iosId = unitIds[type]!['ios'];

      buffer.writeln("  static String get ${methodName}AdUnitId {");
      buffer.writeln("    if (Platform.isAndroid) {");
      buffer.writeln("      return '$androidId';");
      buffer.writeln("    } else if (Platform.isIOS) {");
      buffer.writeln("      return '$iosId';");
      buffer.writeln("    }");
      buffer.writeln("    return '';");
      buffer.writeln("  }");
      buffer.writeln("");
    }

    // Interstitial Loader
    if (enabledTypes.contains('interstitial')) {
      buffer.writeln(getLoadInterstitialAdTemplate());
    }

    // Rewarded Loader
    if (enabledTypes.contains('rewarded')) {
      buffer.writeln(getLoadRewardedAdTemplate());
    }

    buffer.writeln("}");
    serviceFile.writeAsStringSync(buffer.toString());

    // Update Barrel
    final barrelFile = File(
      p.join(activePath, 'lib', 'core', 'services', 'z_services.dart'),
    );
    const exportLine = "export 'ad_service.dart';\n";
    if (!barrelFile.existsSync()) {
      barrelFile.writeAsStringSync(exportLine);
    } else {
      String content = barrelFile.readAsStringSync();
      if (!content.contains('ad_service.dart')) {
        barrelFile.writeAsStringSync('$content$exportLine');
      }
    }
  });
}

String _toCamelCase(String text) {
  final words = text.split('_');
  if (words.isEmpty) return text;
  final result = StringBuffer(words[0]);
  for (int i = 1; i < words.length; i++) {
    result.write(words[i][0].toUpperCase() + words[i].substring(1));
  }
  return result.toString();
}
