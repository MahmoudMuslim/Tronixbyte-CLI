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
