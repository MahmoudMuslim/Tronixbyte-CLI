String getMapperTemplate(
  String projectName,
  String namePascal, [
  List<Map<String, String>>? fields,
]) {
  final toEntityFields = fields != null && fields.isNotEmpty
      ? fields.map((f) => "      ${f['name']}: ${f['name']},").join('\n')
      : "";
  final fromEntityFields = fields != null && fields.isNotEmpty
      ? fields.map((f) => "      ${f['name']}: entity.${f['name']},").join('\n')
      : "";

  return """
import 'package:$projectName/$projectName.dart';

extension ${namePascal}Mapper on ${namePascal}Model {
  ${namePascal}Entity toEntity() => ${namePascal}Entity(
$toEntityFields
  );
}

extension ${namePascal}EntityMapper on ${namePascal}Entity {
  ${namePascal}Model toModel() => ${namePascal}Model(
$fromEntityFields
  );
}
""";
}
