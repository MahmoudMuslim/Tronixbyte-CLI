import 'package:tools/tools.dart';

Future<void> configureUi(String projectName) async {
  printSection('UI & Extensions Configuration');

  await loadingSpinner(
    'Scaffolding UI foundations, routes, and utilities',
    () async {
      // 1. Generate Context Extensions
      final utilsDir = Directory('lib/core/utils');
      if (!utilsDir.existsSync()) {
        utilsDir.createSync(recursive: true);
      }

      final contextExtensionsFile = File(
        'lib/core/utils/context_extensions.dart',
      );
      contextExtensionsFile.writeAsStringSync(
        getContextExtensionsTemplate(projectName),
      );
      printInfo('Generated: lib/core/utils/context_extensions.dart');

      // 2. Generate Bloc Observer
      final blocObserverFile = File('lib/core/utils/bloc_observer.dart');
      blocObserverFile.writeAsStringSync(getBlocObserverTemplate(projectName));
      printInfo('Generated: lib/core/utils/bloc_observer.dart');

      // 3. Generate App Config
      final appConfigFile = File('lib/core/utils/app_config.dart');
      appConfigFile.writeAsStringSync(getAppConfigTemplate(projectName));
      printInfo('Generated: lib/core/utils/app_config.dart');

      // 4. Generate Responsive Helper Widget
      final widgetsDir = Directory('lib/shared/widgets');
      if (!widgetsDir.existsSync()) {
        widgetsDir.createSync(recursive: true);
      }
      final responsiveFile = File('lib/shared/widgets/responsive.dart');
      responsiveFile.writeAsStringSync(
        getResponsiveHelperTemplate(projectName),
      );
      printInfo('Generated: lib/shared/widgets/responsive.dart');

      // 5. Generate App Scaffold
      final scaffoldFile = File('lib/shared/widgets/app_scaffold.dart');
      scaffoldFile.writeAsStringSync(getAppScaffoldTemplate(projectName));
      printInfo('Generated: lib/shared/widgets/app_scaffold.dart');

      // 6. Generate Error Boundary
      final errorBoundaryFile = File(
        'lib/shared/widgets/app_error_boundary.dart',
      );
      errorBoundaryFile.writeAsStringSync(
        getErrorBoundaryTemplate(projectName),
      );
      printInfo('Generated: lib/shared/widgets/app_error_boundary.dart');

      // 7. Generate Landing Page
      final landingPageFile = File('lib/shared/widgets/landing_page.dart');
      landingPageFile.writeAsStringSync(getLandingPageTemplate(projectName));
      printInfo('Generated: lib/shared/widgets/landing_page.dart');

      // 8. Generate Router
      final routesDir = Directory('lib/core/routes');
      if (!routesDir.existsSync()) {
        routesDir.createSync(recursive: true);
      }
      final routerFile = File('lib/core/routes/router.dart');
      routerFile.writeAsStringSync(getRouterTemplate(projectName));
      printInfo('Generated: lib/core/routes/router.dart');

      // Update barrel files
      _updateBarrels(projectName);
    },
  );

  printSuccess(
    'UI, Routes, Config & Utils foundations configured successfully!',
  );
}

void _updateBarrels(String projectName) {
  // 1. Utils Barrel
  File('lib/core/utils/z_utils.dart').writeAsStringSync(
    "export 'context_extensions.dart';\nexport 'bloc_observer.dart';\nexport 'app_config.dart';",
  );

  // 2. Widgets Barrel
  File('lib/shared/widgets/z_widgets.dart').writeAsStringSync(
    "export 'responsive.dart';\nexport 'app_scaffold.dart';\nexport 'app_error_boundary.dart';\nexport 'landing_page.dart';",
  );

  // 3. Routes Barrel
  File(
    'lib/core/routes/z_routes.dart',
  ).writeAsStringSync("export 'router.dart';");

  // 4. Shared Root Barrel
  File(
    'lib/shared/z_shared.dart',
  ).writeAsStringSync("export 'widgets/z_widgets.dart';");

  // 5. Project Root Barrel
  File('lib/$projectName.dart').writeAsStringSync(
    "export 'injection.dart';\nexport 'main.dart';\nexport 'app.dart';\nexport 'src/z_src.dart';\nexport 'core/z_core.dart';\nexport 'shared/z_shared.dart';",
  );
}
