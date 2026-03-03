String getFeatureInjectionTemplate(
  String projectName,
  String namePascal,
  String logicClass,
  bool needDomain,
  bool needData,
  String type,
) {
  final List<String> injections = [];

  // Logic
  if (type == 'bloc' || type == 'cubit') {
    injections.add("  sl.registerFactory(() => $logicClass());");
  } else {
    injections.add("  sl.registerLazySingleton(() => $logicClass());");
  }

  // Use cases
  if (needDomain) {
    injections.add(
      "  sl.registerLazySingleton(() => ${namePascal}UseCase(sl()));",
    );
  }

  // Repositories
  if (needData && needDomain) {
    injections.add(
      "  sl.registerLazySingleton<${namePascal}Repository>(() => ${namePascal}RepositoryImpl(dataSource: sl(), networkInfo: sl()));",
    );
  }

  // Data sources
  if (needData) {
    injections.add(
      "  sl.registerLazySingleton<${namePascal}DataSource>(() => ${namePascal}DataSourceImpl(sl()));",
    );
  }

  return """
import 'package:$projectName/$projectName.dart';

Future<void> init${namePascal}Injection() async {
  // --- $namePascal Feature ---
${injections.join('\n')}
}
""";
}
