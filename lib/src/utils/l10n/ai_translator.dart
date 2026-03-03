import 'package:tools/tools.dart';

Future<void> runAiTranslator() async {
  printSection('🌍 Localization AI Translator (Gemini)');

  final enFile = File('assets/translations/en.json');
  if (!enFile.existsSync()) {
    printError(
      'Source translation file not found: assets/translations/en.json',
    );
    return;
  }

  printInfo('This tool uses Google Gemini AI to translate your strings.');
  printInfo('Get a FREE API Key at: https://aistudio.google.com/app/apikey');

  final apiKey = ask('Enter your Gemini API Key');
  if (apiKey == null) return;

  final targetLang =
      ask('Enter target language code (e.g., ar, es, fr, de)') ?? 'ar';
  final targetPath = 'assets/translations/$targetLang.json';

  await loadingSpinner(
    'Translating strings to ${targetLang.toUpperCase()}',
    () async {
      try {
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );
        final enContent = enFile.readAsStringSync();

        final prompt =
            """
      You are a professional mobile app translator. 
      Translate the following JSON map from English to language code: $targetLang.
      Maintain the same JSON keys. Only translate the values.
      Keep technical terms like "ID", "URL", or placeholders like "{name}" unchanged.
      Output ONLY the raw JSON string.
      
      Source JSON:
      $enContent
      """;

        final response = await model.generateContent([Content.text(prompt)]);
        final translatedJson = response.text;

        if (translatedJson != null) {
          // Simple cleanup in case AI includes markdown blocks
          final cleanJson = translatedJson
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();

          final targetFile = File(targetPath);
          if (!targetFile.parent.existsSync()) {
            targetFile.parent.createSync(recursive: true);
          }

          targetFile.writeAsStringSync(cleanJson, mode: FileMode.write);
        }
      } catch (e) {
        throw Exception('Translation failed: $e');
      }
    },
  );

  printSuccess('Successfully generated: $targetPath');
  printInfo('👉 Review the translations before production use.');
}
