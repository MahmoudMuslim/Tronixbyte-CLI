import 'package:tools/tools.dart';

Future<void> generateApiEndpoint() async {
  printSection('API Endpoint Generator');

  final apiServiceFile = File('lib/core/api/api_service.dart');
  if (!apiServiceFile.existsSync()) {
    printError('ApiService not found at lib/core/api/api_service.dart');
    return;
  }

  final name = ask('Endpoint name (e.g., login, getUser)');
  if (name == null) return;

  final method = (ask('HTTP Method (GET/POST/PUT/DELETE)') ?? 'GET')
      .toUpperCase();
  final path = ask('Endpoint path (e.g., /auth/login)');
  if (path == null) return;

  final responseModel =
      ask('Response Model name (e.g., LoginResponse)') ?? 'dynamic';

  await loadingSpinner('Adding endpoint to ApiService', () async {
    String content = apiServiceFile.readAsStringSync();
    final methodSignature =
        """
  @$method('$path')
  Future<$responseModel> $name();
""";

    if (!content.contains('Future<$responseModel> $name()')) {
      final lastBraceIndex = content.lastIndexOf('}');
      if (lastBraceIndex != -1) {
        content =
            content.substring(0, lastBraceIndex) +
            methodSignature +
            content.substring(lastBraceIndex);
        apiServiceFile.writeAsStringSync(content);
      }
    } else {
      printWarning('Endpoint already exists in ApiService.');
    }
  });

  printSuccess('Endpoint "$name" added to ApiService successfully.');
  printInfo(
    'Tip: Remember to create the $responseModel in your feature models!',
  );
}
