import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> configureDatabase() async {
  printSection('Database Configuration (Drift)');

  final activePath = getActiveProjectPath();

  // 1. Ensure dependencies are present
  await loadingSpinner('Ensuring database dependencies', () async {
    await runCommand('flutter', ['pub', 'add', ...databaseDeps]);
    await runCommand('flutter', ['pub', 'add', '--dev', ...databaseDevDeps]);
  });

  // 2. Ask for database file path
  final dbPath = ask(
    'Enter the database file path (e.g., /path/to/my.db) [Leave empty to skip asset copy]',
  );
  String? dbFileName;

  if (dbPath != null && File(dbPath).existsSync()) {
    dbFileName = p.basename(dbPath);
    // Copy database file to assets/database/
    final dbTargetDir = Directory(p.join(activePath, 'assets', 'database'));
    if (!dbTargetDir.existsSync()) {
      dbTargetDir.createSync(recursive: true);
    }
    File(dbPath).copySync(p.join(dbTargetDir.path, dbFileName));
    _updatePubspecWithDatabase(activePath);
  }

  // 3. Ask for schema file path
  final schemaPath = ask(
    'Enter the schema file path (.drift or .sql) [Leave empty for blank table list]',
  );
  String? finalSchemaFileName;

  if (schemaPath != null && File(schemaPath).existsSync()) {
    final extension = p.extension(schemaPath).toLowerCase();
    final fileNameWithoutExt = p.basenameWithoutExtension(schemaPath);

    final schemaTargetDir = Directory(
      p.join(activePath, 'lib', 'core', 'database'),
    );
    if (!schemaTargetDir.existsSync()) {
      schemaTargetDir.createSync(recursive: true);
    }

    if (extension == '.sql') {
      finalSchemaFileName = '$fileNameWithoutExt.drift';
      File(
        schemaPath,
      ).copySync(p.join(schemaTargetDir.path, finalSchemaFileName));
      printInfo(
        'Renamed and copied .sql schema to lib/core/database/$finalSchemaFileName',
      );
    } else if (extension == '.drift') {
      finalSchemaFileName = p.basename(schemaPath);
      File(
        schemaPath,
      ).copySync(p.join(schemaTargetDir.path, finalSchemaFileName));
      printInfo(
        'Copied .drift schema to lib/core/database/$finalSchemaFileName',
      );
    }
  }

  await loadingSpinner('Initializing database infrastructure', () async {
    final driftAnnotation = finalSchemaFileName != null
        ? "include: {'$finalSchemaFileName'}"
        : "tables: []";

    final dbDir = Directory(p.join(activePath, 'lib', 'core', 'database'));
    if (!dbDir.existsSync()) dbDir.createSync(recursive: true);

    final dbConDir = Directory(p.join(dbDir.path, 'connection'));
    if (!dbConDir.existsSync()) dbConDir.createSync(recursive: true);

    final dbToolsDir = Directory(p.join(activePath, 'tool'));
    if (!dbToolsDir.existsSync()) dbToolsDir.createSync(recursive: true);

    final actualDbName = dbFileName ?? 'app_database.db';

    // Generate Database files
    final projectName = await getProjectName();
    File(
      p.join(dbDir.path, 'app_database.dart'),
    ).writeAsStringSync(getDatabaseTemplate(driftAnnotation));

    File(p.join(dbConDir.path, 'native.dart')).writeAsStringSync(
      getDatabaseNativeTemplate(
        isDbInAssets: dbFileName != null,
      ).replaceAll('app_database.db', actualDbName),
    );

    File(p.join(dbConDir.path, 'web.dart')).writeAsStringSync(
      getDatabaseWebTemplate(
        isDbInAssets: dbFileName != null,
      ).replaceAll('app_database.db', actualDbName),
    );

    File(
      p.join(dbConDir.path, 'unsupported.dart'),
    ).writeAsStringSync(getDatabaseUnsupportedTemplate());
    File(
      p.join(dbConDir.path, 'shared.dart'),
    ).writeAsStringSync(getDatabaseSharedTemplate());

    File(
      p.join(dbToolsDir.path, 'builder.dart'),
    ).writeAsStringSync(getDatabaseToolTemplate());
    File(
      p.join(activePath, 'build.yaml'),
    ).writeAsStringSync(getDatabaseBuildYamlTemplate());

    final webDir = Directory(p.join(activePath, 'web'));
    if (!webDir.existsSync()) webDir.createSync(recursive: true);
    File(
      p.join(webDir.path, 'worker.dart'),
    ).writeAsStringSync(getDatabaseWorkerTemplate());

    File(
      p.join(dbDir.path, 'z_database.dart'),
    ).writeAsStringSync("export 'app_database.dart';");
  });

  // Artifact downloads
  await loadingSpinner('Downloading drift worker and sqlite3 wasm', () async {
    final urlWorker = Uri.parse(
      'https://github.com/simolus3/drift/releases/latest/download/drift_worker.js',
    );
    final urlWasm = Uri.parse(
      'https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.9.4/sqlite3.wasm',
    );

    try {
      final workerRes = await http.get(urlWorker);
      final wasmRes = await http.get(urlWasm);

      final webDir = Directory(p.join(activePath, 'web'));
      if (!webDir.existsSync()) webDir.createSync();

      File(
        p.join(webDir.path, 'drift_worker.js'),
      ).writeAsBytesSync(workerRes.bodyBytes);
      File(
        p.join(webDir.path, 'sqlite3.wasm'),
      ).writeAsBytesSync(wasmRes.bodyBytes);
    } catch (e) {
      printWarning(
        'Could not download web artifacts (Drift/SQLite). You may need to add them manually for web support.',
      );
    }
  });

  printSuccess('Database configuration completed successfully!');
  printInfo('👉 Remember to run build_runner to generate the .g.dart file.');
}

void _updatePubspecWithDatabase(String activePath) {
  final file = File(p.join(activePath, 'pubspec.yaml'));
  if (!file.existsSync()) return;
  String content = file.readAsStringSync();

  const assetPath = '    - assets/database/';
  if (!content.contains(assetPath)) {
    if (content.contains('  assets:')) {
      content = content.replaceFirst('  assets:', '  assets:\n$assetPath');
    } else if (content.contains('flutter:')) {
      content = content.replaceFirst(
        'flutter:',
        'flutter:\n  assets:\n$assetPath',
      );
    }
    file.writeAsStringSync(content);
    printInfo('Updated pubspec.yaml with assets/database/');
  }
}
