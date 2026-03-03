import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> enforceNamingConventions() async {
  printSection('Naming Convention Enforcer');

  final activePath = getActiveProjectPath();
  final libDir = Directory(p.join(activePath, 'lib'));
  if (!libDir.existsSync()) {
    printError('lib directory not found at ${libDir.path}');
    return;
  }

  int renamedCount = 0;
  final List<FileSystemEntity> entities = libDir.listSync(recursive: true);

  await loadingSpinner(
    'Enforcing snake_case naming conventions across lib/ in $activePath',
    () async {
      for (final entity in entities) {
        final name = p.basename(entity.path);
        if (name.startsWith('.') || name.startsWith('z_')) continue;

        final snakeCaseName = _toSnakeCase(name);
        if (name != snakeCaseName) {
          final newPath = p.join(entity.parent.path, snakeCaseName);
          entity.renameSync(newPath);
          printInfo('Renamed: $name -> $snakeCaseName');
          renamedCount++;
        }
      }
    },
  );

  if (renamedCount > 0) {
    printSuccess(
      'Naming convention enforcement complete! $renamedCount items renamed.',
    );
  } else {
    printInfo('All files already follow snake_case conventions.');
  }
}

String _toSnakeCase(String name) {
  return name
      .replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => '_${match.group(1)!.toLowerCase()}',
      )
      .replaceAll(RegExp(r'[-\s]+'), '_')
      .replaceAll(RegExp(r'^_'), '')
      .replaceAll(RegExp(r'_{2,}'), '_')
      .toLowerCase();
}
