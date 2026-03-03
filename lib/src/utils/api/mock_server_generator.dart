import 'package:tools/tools.dart';

Future<void> runApiMockServerGenerator() async {
  printSection('🛡️ Advanced API Mock Server');

  final apiServiceFile = File('lib/core/api/api_service.dart');
  if (!apiServiceFile.existsSync()) {
    printError('lib/core/api/api_service.dart not found. Scaffold API first.');
    return;
  }

  printInfo(
    'This tool will scaffold a local Mock API server based on your ApiService.',
  );

  await loadingSpinner(
    'Analyzing ApiService and generating mock server',
    () async {
      final projectName = await getProjectName();
      final content = apiServiceFile.readAsStringSync();

      // Extract endpoints
      final endpointRegex = RegExp(
        r'@(?:GET|POST|PUT|DELETE|PATCH)\(["'
        '](.+?)["'
        ']\)\s+Future<(.+?)>\s+(\w+)\(',
      );
      final matches = endpointRegex.allMatches(content);

      if (matches.isEmpty) {
        printWarning('No endpoints found in ApiService.');
        return;
      }

      final List<String> routes = [];
      for (final match in matches) {
        final path = match.group(1)!;
        final method = content.substring(match.start, match.end).contains('GET')
            ? 'get'
            : content.substring(match.start, match.end).contains('POST')
            ? 'post'
            : 'all';
        final methodName = match.group(3)!;

        routes.add("""
  server.$method('$path', (request) {
    return Response.ok(json.encode({'message': 'Mock response for $methodName'}), headers: {'content-type': 'application/json'});
  });""");
      }

      final serverContent =
          """
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final server = Router();

  // Generated Routes
${routes.join('\n')}

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(server);

  final ioServer = await io.serve(handler, 'localhost', 8080);
  print('🚀 Mock Server running on localhost:\${ioServer.port}');
}
""";

      final mockServerFile = File('test/mock_server.dart');
      if (!mockServerFile.parent.existsSync())
        mockServerFile.parent.createSync(recursive: true);
      mockServerFile.writeAsStringSync(serverContent.trim());
    },
  );

  printSuccess('Mock server generated: test/mock_server.dart');
  printInfo('👉 Run with: "dart test/mock_server.dart"');
  printWarning(
    '👉 Action Required: Add "shelf" and "shelf_router" to dev_dependencies.',
  );

  ask('Press Enter to return');
}
