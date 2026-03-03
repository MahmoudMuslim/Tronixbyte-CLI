String getDatabaseTemplate(String driftAnnotation) =>
    """
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'connection/shared.dart';

part 'app_database.g.dart';

@DriftDatabase($driftAnnotation)
class AppDatabase extends _\$AppDatabase {
  AppDatabase() : super(openConnection());
  
  static AppDatabase init() => constructDb();

  @override
  int get schemaVersion => 1;
  
}
""";

String getDatabaseNativeTemplate({bool isDbInAssets = false}) =>
    """
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../app_database.dart';

AppDatabase constructDb() => AppDatabase();

QueryExecutor openConnection() {
  ${isDbInAssets ? "return driftDatabase(name: 'app_database');" : """
  return driftDatabase(
    // By default, drift creates a file named app.sqlite based on the name here.
    // Because we need to interact with the underlying file, we add the
    // `databasePath` option to specify the exact path here.
    name: 'app_database',
    native: DriftNativeOptions(
      databasePath: () async {
        // put the database file, called db.sqlite here, into the documents
        // folder for your app.
        final dbFolder = await getApplicationDocumentsDirectory();
        final file = File(p.join(dbFolder.path, '\$name.db'));

        if (!await file.exists()) {
          // Extract the pre-populated database file from assets
          final blob = await rootBundle.load('assets/database/\$name.db');
          final buffer = blob.buffer;
          await file.writeAsBytes(
            buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes),
          );
        }

        return file.path;
      },
    ));
  """}
}
    """;

String getDatabaseWebTemplate({bool isDbInAssets = false}) =>
    """
import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../app_database.dart';

AppDatabase constructDb() => AppDatabase();

QueryExecutor openConnection() {
  return driftDatabase(
    name: 'app_database',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      ${isDbInAssets ? """
      initializeDatabase: () async {
        final data = await rootBundle.load('assets/database/\$name.db');
        return data.buffer.asUint8List();
      },
      """ : ""}
      onResult: (WasmDatabaseResult result) {
        if (result.missingFeatures.isNotEmpty) {
          // Depending how central local persistence is to your app, you may want
          // to show a warning to the user if only unrealiable implemetentations
          // are available.
          log(
            'Using \${result.chosenImplementation} due to missing browser '
            'features: \${result.missingFeatures}',
          );
        }
      },
    ));
}
    """;

String getDatabaseUnsupportedTemplate() => """
// unsupported.dart
import 'package:drift/drift.dart';

import '../app_database.dart';

AppDatabase constructDb() => AppDatabase();

QueryExecutor openConnection() => throw UnimplementedError();
    """;

String getDatabaseSharedTemplate() => """
// shared.dart
export 'unsupported.dart'
  if (dart.library.ffi) 'native.dart'
  if (dart.library.js_interop) 'web.dart';
    """;

String getDatabaseToolTemplate() => """
import 'package:build/build.dart';

/// Builder that copies the (hidden, `build_to: cache`) output of
/// `build_web_compilers` into `web/` (visible, this builder is defined with
/// `build_to: source`).
class CopyCompiledJs extends Builder {
  CopyCompiledJs([BuilderOptions? options]);

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = AssetId(buildStep.inputId.package, 'web/worker.dart.js');
    final input = await buildStep.readAsBytes(inputId);
    await buildStep.writeAsBytes(buildStep.allowedOutputs.single, input);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        r'\$package\$': ['web/drift_worker.js']
      };
}
""";

String getDatabaseBuildYamlTemplate() => """
# This configures how `build_runner` and associated builders should behave.
# For more information, see https://pub.dev/packages/build_config

targets:
  \$default:
    # Reducing sources makes the build slightly faster (some of these are required
    # to exist in the default target).
    sources:
      - lib/**
      - web/**
      - "tool/**"
      - pubspec.yaml
      - lib/\$lib\$
      - \$package\$
    builders:
      drift_dev:
        # These options change how drift generates code
        options:
          databases:
            default: lib/core/database/app_database.dart
          # Drift analyzes SQL queries at compile-time. For this purpose, it needs to know which sqlite3
          # features will be available. The sqlite3 package enables fts5 by default, so we can depend
          # on that.
          sql:
            dialect: sqlite
            options:
              version: "3.38"
              modules: [fts5]

      # Configuring this builder isn't required for most apps. In our case, we
      # want to compile the web worker in `web/worker.dart` to JS and we use the
      # build system for that.
      build_web_compilers:entrypoint:
        generate_for:
          - web/worker.dart
        options:
          compiler: dart2js

  # JS outputs by the build system are private, we use a `build_to: source` builder
  # afterwards to make them visible in `web/`.
  copy_js:
    auto_apply_builders: false
    dependencies: [\$default]
    builders:
      ":copy_compiled_worker_js":
        enabled: true

# build_web_compilers writes a hidden asset, but we want an asset in `web/` for
# flutter to see. So, copy that output. Again, this is not needed for most apps.
builders:
  copy_compiled_worker_js:
    import: "tool/builder.dart"
    builder_factories: ["CopyCompiledJs.new"]
    build_to: source
    build_extensions: { "web/worker.dart.js": ["web/drift_worker.js"] }
""";

String getDatabaseWorkerTemplate() => """
import 'package:drift/wasm.dart';

/// This Dart program is the entrypoint of a web worker that will be compiled to
/// JavaScript by running `build_runner build`. The resulting JavaScript file
/// (`shared_worker.dart.js`) is part of the build result and will be shipped
/// with the rest of the application when running or building a Flutter web app.
void main() {
  return WasmDatabase.workerMainForOpen();
}
""";
