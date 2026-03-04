import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> configureUi(String projectName) async {
  printSection('UI & Extensions Configuration');

  final activePath = getActiveProjectPath();

  await loadingSpinner(
    'Scaffolding UI foundations, routes, and utilities',
    () async {
      // 1. Generate Context Extensions
      final utilsDir = Directory(p.join(activePath, 'lib', 'core', 'utils'));
      if (!utilsDir.existsSync()) {
        utilsDir.createSync(recursive: true);
      }

      final contextExtensionsFile = File(
        p.join(utilsDir.path, 'context_extensions.dart'),
      );
      contextExtensionsFile.writeAsStringSync(
        getContextExtensionsTemplate(projectName),
      );
      printInfo('Generated: ${contextExtensionsFile.path}');

      // 2. Generate Bloc Observer
      final blocObserverFile = File(
        p.join(utilsDir.path, 'bloc_observer.dart'),
      );
      blocObserverFile.writeAsStringSync(getBlocObserverTemplate(projectName));
      printInfo('Generated: ${blocObserverFile.path}');

      // 3. Generate App Config
      final appConfigFile = File(p.join(utilsDir.path, 'app_config.dart'));
      appConfigFile.writeAsStringSync(getAppConfigTemplate(projectName));
      printInfo('Generated: ${appConfigFile.path}');

      // 4. Generate Responsive Helper Widget
      final widgetsDir = Directory(
        p.join(activePath, 'lib', 'shared', 'widgets'),
      );
      if (!widgetsDir.existsSync()) {
        widgetsDir.createSync(recursive: true);
      }
      final responsiveFile = File(p.join(widgetsDir.path, 'responsive.dart'));
      responsiveFile.writeAsStringSync(
        getResponsiveHelperTemplate(projectName),
      );
      printInfo('Generated: ${responsiveFile.path}');

      // 5. Generate App Scaffold
      final scaffoldFile = File(p.join(widgetsDir.path, 'app_scaffold.dart'));
      scaffoldFile.writeAsStringSync(getAppScaffoldTemplate(projectName));
      printInfo('Generated: ${scaffoldFile.path}');

      // 6. Generate Error Boundary
      final errorBoundaryFile = File(
        p.join(widgetsDir.path, 'app_error_boundary.dart'),
      );
      errorBoundaryFile.writeAsStringSync(
        getErrorBoundaryTemplate(projectName),
      );
      printInfo('Generated: ${errorBoundaryFile.path}');

      // 7. Generate Landing Page
      final landingPageFile = File(
        p.join(widgetsDir.path, 'landing_page.dart'),
      );
      landingPageFile.writeAsStringSync(getLandingPageTemplate(projectName));
      printInfo('Generated: ${landingPageFile.path}');

      // 8. Generate Router
      final routesDir = Directory(p.join(activePath, 'lib', 'core', 'routes'));
      if (!routesDir.existsSync()) {
        routesDir.createSync(recursive: true);
      }
      final routerFile = File(p.join(routesDir.path, 'router.dart'));
      routerFile.writeAsStringSync(getRouterTemplate(projectName));
      printInfo('Generated: ${routerFile.path}');

      // Update barrel files
      _updateBarrels(projectName, activePath);
    },
  );

  printSuccess(
    'UI, Routes, Config & Utils foundations configured successfully!',
  );
}

void _updateBarrels(String projectName, String activePath) {
  // 1. Utils Barrel
  File(
    p.join(activePath, 'lib', 'core', 'utils', 'z_utils.dart'),
  ).writeAsStringSync(
    "export 'context_extensions.dart';\nexport 'bloc_observer.dart';\nexport 'app_config.dart';",
  );

  // 2. Widgets Barrel
  File(
    p.join(activePath, 'lib', 'shared', 'widgets', 'z_widgets.dart'),
  ).writeAsStringSync(
    "export 'responsive.dart';\nexport 'app_scaffold.dart';\nexport 'app_error_boundary.dart';\nexport 'landing_page.dart';",
  );

  // 3. Routes Barrel
  File(
    p.join(activePath, 'lib', 'core', 'routes', 'z_routes.dart'),
  ).writeAsStringSync("export 'router.dart';");

  // 4. Shared Root Barrel
  File(
    p.join(activePath, 'lib', 'shared', 'z_shared.dart'),
  ).writeAsStringSync("export 'widgets/z_widgets.dart';");

  // 5. Project Root Barrel
  File(p.join(activePath, 'lib', '$projectName.dart')).writeAsStringSync(
    "export 'injection.dart';\nexport 'main.dart';\nexport 'app.dart';\nexport 'src/z_src.dart';",
  );
}
