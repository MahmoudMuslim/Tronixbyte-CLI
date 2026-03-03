String getServerMainTemplate(List<String> routes) {
  return """
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
}

String getServerResponseTemplate(
  String method,
  String path,
  String methodName,
) {
  return """
server.$method('$path', (request) {
  return Response.ok(json.encode({'message': 'Mock response for $methodName'}), headers: {'content-type': 'application/json'});
});""";
}

String getMockGeneratorTemplate(
  String projectName,
  String packageImportPath,
  String mockClassName,
  String className,
) {
  return """
import 'package:mocktail/mocktail.dart';
import 'package:$projectName/$packageImportPath';

class $mockClassName extends Mock implements $className {}
""";
}
