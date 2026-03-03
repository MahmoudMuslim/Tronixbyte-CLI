String getDataSourceTemplate(String projectName, String namePascal) =>
    """
import 'package:$projectName/$projectName.dart';

abstract class ${namePascal}DataSource {
  Future<${namePascal}Model> getData();
}

class ${namePascal}DataSourceImpl implements ${namePascal}DataSource {
  final ApiService apiService;
  ${namePascal}DataSourceImpl(this.apiService);

  @override
  Future<${namePascal}Model> getData() async {
    return await apiService.get$namePascal();
  }
}
""";

String getModelTemplate(
  String projectName,
  String name,
  String namePascal, [
  List<Map<String, String>>? fields,
]) {
  final fieldsExist = fields != null && fields.isNotEmpty;

  final constructorParams = fieldsExist
      ? "{\n${fields.map((f) => "    required super.${f['name']},").join('\n')}\n  }"
      : "";

  return """
import 'package:$projectName/$projectName.dart';

part '${name}_model.g.dart';

@JsonSerializable()
class ${namePascal}Model extends ${namePascal}Entity {
  const ${namePascal}Model($constructorParams);

  factory ${namePascal}Model.fromJson(Map<String, dynamic> json) => _\$${namePascal}ModelFromJson(json);
  Map<String, dynamic> toJson() => _\$${namePascal}ModelToJson(this);
}
""";
}

String getRepositoryImplTemplate(String projectName, String namePascal) =>
    """
import 'package:$projectName/$projectName.dart';

class ${namePascal}RepositoryImpl implements ${namePascal}Repository {
  final ${namePascal}DataSource dataSource;
  final NetworkInfo networkInfo;
  
  ${namePascal}RepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ${namePascal}Entity>> getData() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await dataSource.getData();
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(OfflineFailure('No Internet Connection'));
    }
  }
}
""";
