import 'package:tools/tools.dart';

String getVSCodeExtensionsTemplate() {
  final extensions = [
    "Dart-Code.flutter",
    "Dart-Code.dart-code",
    "formulahendry.terminal",
    "FelixAngelov.bloc",
    "Nash.awesome-flutter-snippets",
    "steo.easy-localization-helper",
    "RobertBrunhage.flutter-riverpod-snippets",
    "HillelCoren.flutter-getx",
  ];

  return """
{
  "recommendations": ${jsonEncode(extensions)}
}
""";
}

String getFlavorConfigTemplate(String projectName) {
  return """
  flavorDimensions "default"

  productFlavors {
      dev {
          dimension "default"
          resValue "string", "app_name", "$projectName (Dev)"
          applicationIdSuffix ".dev"
      }
      stg {
          dimension "default"
          resValue "string", "app_name", "$projectName (Stg)"
          applicationIdSuffix ".stg"
      }
      prod {
          dimension "default"
          resValue "string", "app_name", "$projectName"
      }
  }
""";
}

String getFlavorConfigIOSTemplate(String flavor, String projectName) {
  return """
#include "Generated.xcconfig"
#include "AppFrameworkInfo.xcconfig"

FLUTTER_TARGET=lib/main_$flavor.dart
ASSET_PREFIX=$flavor
APP_NAME=$projectName ${flavor.toUpperCase()}
""";
}
