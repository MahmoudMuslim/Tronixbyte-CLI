import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> generateVsCodeSnippets() async {
  printSection('VS Code Snippet Generator');

  final activePath = getActiveProjectPath();

  final snippets = {
    "Clean Feature Bloc": {
      "prefix": "tb-bloc",
      "body": [
        "class \${1:Name}Bloc extends HydratedBloc<\${1}Event, \${1}State> {",
        "  \${1}Bloc() : super(\${1}Initial()) {",
        "    on<\${1}Event>((event, emit) {",
        "      // TODO: implement event handler",
        "    });",
        "  }",
        "",
        "  @override",
        "  \${1}State? fromJson(Map<String, dynamic> json) => null;",
        "",
        "  @override",
        "  Map<String, dynamic>? toJson(\${1}State state) => null;",
        "}",
      ],
      "description": "Generate a Clean Architecture BLoC",
    },
    "Clean Repository": {
      "prefix": "tb-repo",
      "body": [
        "abstract class \${1:Name}Repository {",
        "  Future<Either<Failure, \${2:dynamic}>> get\${1}Data();",
        "}",
        "",
        "class \${1}RepositoryImpl implements \${1}Repository {",
        "  final \${1}DataSource dataSource;",
        "  \${1}RepositoryImpl(this.dataSource);",
        "",
        "  @override",
        "  Future<Either<Failure, \${2}>> get\${1}Data() async {",
        "    try {",
        "      final result = await dataSource.get\${1}();",
        "      return Right(result);",
        "    } catch (e) {",
        "      return Left(ServerFailure(e.toString()));",
        "    }",
        "  }",
        "}",
      ],
      "description": "Generate Repository Interface and Implementation",
    },
    "Clean UseCase": {
      "prefix": "tb-usecase",
      "body": [
        "class \${1:Name}UseCase {",
        "  final \${1}Repository repository;",
        "  \${1}UseCase(this.repository);",
        "",
        "  Future<Either<Failure, \${2:dynamic}>> call() async {",
        "    return await repository.get\${1}Data();",
        "  }",
        "}",
      ],
      "description": "Generate a UseCase",
    },
  };

  await loadingSpinner(
    'Generating .vscode/tronixbyte.code-snippets in $activePath',
    () async {
      final vscodeDir = Directory(p.join(activePath, '.vscode'));
      if (!vscodeDir.existsSync()) vscodeDir.createSync(recursive: true);

      final file = File(p.join(vscodeDir.path, 'tronixbyte.code-snippets'));
      file.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(snippets),
      );
    },
  );

  printSuccess('VS Code snippets generated successfully!');
  printInfo(
    'Try shortcuts like "tb-bloc", "tb-repo", "tb-usecase" in VS Code.',
  );
}
