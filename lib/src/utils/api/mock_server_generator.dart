import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> runApiMockServerGenerator() async {
  printSection('🛡️ Advanced API Mock Server');

  final activePath = getActiveProjectPath();
  final apiServiceFile = File(
    p.join(activePath, 'lib', 'core', 'api', 'api_service.dart'),
  );

  if (!apiServiceFile.existsSync()) {
    printError(
      'lib/core/api/api_service.dart not found at ${apiServiceFile.path}. Scaffold API first.',
    );
    return;
  }

  printInfo(
    'This tool will scaffold a local Mock API server based on your ApiService.',
  );

  await loadingSpinner(
    'Analyzing ApiService and generating mock server',
    () async {
      final content = apiServiceFile.readAsStringSync();

      // Extract endpoints
      final endpointRegex = RegExp(
        r'''@(?:GET|POST|PUT|DELETE|PATCH)\(["'](.+?)["']\)\s+Future<(.+?)>\s+(\w+)\(''',
      );
      final matches = endpointRegex.allMatches(content);

      if (matches.isEmpty) {
        printWarning('No endpoints found in ApiService.');
        return;
      }

      final List<String> routes = [];
      for (final match in matches) {
        final path = match.group(1)!;
        final matchedText = match.group(0)!;
        final method = matchedText.contains('GET')
            ? 'get'
            : matchedText.contains('POST')
            ? 'post'
            : 'all';
        final methodName = match.group(3)!;

        routes.add(getServerResponseTemplate(method, path, methodName));
      }

      final serverContent = getServerMainTemplate(routes);

      final mockServerFile = File(
        p.join(activePath, 'test', 'mock_server.dart'),
      );
      if (!mockServerFile.parent.existsSync()) {
        mockServerFile.parent.createSync(recursive: true);
      }
      mockServerFile.writeAsStringSync(serverContent.trim());
    },
  );

  printSuccess(
    'Mock server generated in active project: test/mock_server.dart',
  );
  printInfo('👉 Run with: "dart test/mock_server.dart"');
  printWarning(
    '👉 Action Required: Add "shelf" and "shelf_router" to dev_dependencies.',
  );

  ask('Press Enter to return');
}
