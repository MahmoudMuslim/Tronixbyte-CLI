String getEntityTemplate(
  String projectName,
  String name,
  String namePascal, [
  List<Map<String, String>>? fields,
]) {
  final fieldsStr = fields != null && fields.isNotEmpty
      ? fields.map((f) => "  final ${f['type']} ${f['name']};").join('\n')
      : "";
  final constructorFields = fields != null && fields.isNotEmpty
      ? "{\n${fields.map((f) => "    required this.${f['name']},").join('\n')}\n  }"
      : "";
  // final propsStr = fields != null && fields.isNotEmpty
  //     ? fields.map((f) => "${f['name']}").join(', ')
  //     : "";

  return """
import 'package:$projectName/$projectName.dart';

part '${name}_entity.g.dart';
@generateProps
class ${namePascal}Entity extends Equatable {
$fieldsStr
  const ${namePascal}Entity($constructorFields);

  @override
  List<Object?> get props => _\$props;
}
""";
}

String getUseCaseTemplate(String projectName, String namePascal) =>
    """
import 'package:$projectName/$projectName.dart';

class ${namePascal}UseCase {
  final ${namePascal}Repository repository;
  ${namePascal}UseCase(this.repository);

  Future/*<Either<Failure, ${namePascal}Entity>>*/ call() async {
    return await repository.getData();
  }
}
""";

String getRepositoryTemplate(String projectName, String namePascal) =>
    """
import 'package:$projectName/$projectName.dart';

abstract class ${namePascal}Repository {
  Future/*<Either<Failure, ${namePascal}Entity>>*/ getData();
}
""";
