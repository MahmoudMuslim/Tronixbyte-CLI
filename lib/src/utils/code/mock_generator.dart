import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> generateMocks() async {
  printSection('🧪 Smart Test Mock Architect');

  final libDir = Directory('lib/features');
  if (!libDir.existsSync()) {
    printError('lib/features directory not found.');
    return;
  }

  final mockDir = Directory('test/mocks');
  if (!mockDir.existsSync()) {
    mockDir.createSync(recursive: true);
  }

  final List<File> filesToScan = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  int generatedCount = 0;
  final List<String> mockExports = [];

  await loadingSpinner(
    'Crawling architecture for injectable interfaces',
    () async {
      for (final file in filesToScan) {
        final content = file.readAsStringSync();

        // Matches: abstract class [Name]Repository OR abstract class [Name]DataSource
        final interfaceRegex = RegExp(
          r'abstract\s+class\s+(\w+(?:Repository|DataSource))',
        );
        final matches = interfaceRegex.allMatches(content);

        for (final match in matches) {
          final className = match.group(1);
          if (className == null) continue;

          final mockClassName = 'Mock$className';
          final mockFileName = '${_toSnakeCase(className)}_mock.dart';
          final mockFilePath = p.join(mockDir.path, mockFileName);

          final projectName = await getProjectName();
          final relativePath = p
              .relative(file.path, from: Directory.current.path)
              .replaceAll('\\', '/');

          final mockContent =
              """
import 'package:mocktail/mocktail.dart';
import 'package:$projectName/$relativePath';

class $mockClassName extends Mock implements $className {}
""";

          File(mockFilePath).writeAsStringSync(mockContent);
          mockExports.add("export '$mockFileName';");
          generatedCount++;
          printInfo('Generated Mock: $mockClassName');
        }
      }

      if (mockExports.isNotEmpty) {
        final barrelFile = File(p.join(mockDir.path, 'z_mocks.dart'));
        barrelFile.writeAsStringSync('${mockExports.join('\n')}\n');
      }
    },
  );

  if (generatedCount > 0) {
    printSuccess(
      'Successfully architected $generatedCount mocks in test/mocks/',
    );
    printInfo('👉 Global Mock Barrel: test/mocks/z_mocks.dart');
  } else {
    printInfo('No Repository or DataSource interfaces found to mock.');
  }
}

String _toSnakeCase(String name) {
  return name
      .replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => '_${match.group(1)!.toLowerCase()}',
      )
      .replaceAll(RegExp(r'^_'), '')
      .toLowerCase();
}
