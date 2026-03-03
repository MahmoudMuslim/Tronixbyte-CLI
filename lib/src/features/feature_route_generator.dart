import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> generateFeatureRoute(
  String name,
  String projectName,
  String namePascal,
) async {
  printSection('Feature Route Registration');

  final activePath = getActiveProjectPath();
  final routesDir = Directory(p.join(activePath, 'lib', 'core', 'routes'));
  if (!routesDir.existsSync()) {
    routesDir.createSync(recursive: true);
  }

  final routerFile = File(p.join(routesDir.path, 'router.dart'));

  await loadingSpinner('Registering $namePascal route in GoRouter', () async {
    // If router.dart doesn't exist, create it from template first
    if (!routerFile.existsSync()) {
      printInfo('Initial router.dart not found. Creating it from template...');
      routerFile.writeAsStringSync(getRouterTemplate(projectName));
      printSuccess('Created: ${routerFile.path}');
    }

    var content = routerFile.readAsStringSync();
    final routeClassName = '${namePascal}Route';

    if (content.contains('class $routeClassName')) {
      printWarning('Route $routeClassName already exists in router.dart.');
      return;
    }

    // Create the route snippet following the getRouterTemplate style
    final routeSnippet = getRouteSnippedTemplate(name, namePascal);

    // Insert before the GoRouter definition to keep the file organized
    final insertionPoint = content.indexOf('final router = GoRouter');
    if (insertionPoint != -1) {
      content =
          '${content.substring(0, insertionPoint)}$routeSnippet\n${content.substring(insertionPoint)}';
    } else {
      // If router definition not found, just append to end
      content += '\n$routeSnippet';
    }

    routerFile.writeAsStringSync(content);
  });

  printSuccess(
    'Route "$namePascal" registered in ${routerFile.path} successfully!',
  );
}
