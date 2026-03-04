String getInjectionTemplate(
  String projectName,
  String stateType, {
  bool enableDatabase = false,
  bool enableNetwork = false,
}) =>
    """
import 'package:$projectName/$projectName.dart';

final sl = GetIt.instance;

Future<void> setupInjection() async {
  // --- Core ---
  ${enableDatabase ? """
  
  
  // Database
  final database = AppDatabase();
  sl.registerSingleton<AppDatabase>(database);
  """ : ""}
  ${enableNetwork ? """
  
  
  // Network Info
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Api
  sl.registerLazySingleton<AppInterceptor>(() => AppInterceptor());
  sl.registerLazySingleton<Dio>(() => DioFactory.getDio());
  sl.registerLazySingleton<ApiService>(() => ApiService(sl<Dio>()));
  
  // Connectivity
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  """ : ""}

  // Package Info
  final packageInfo = await PackageInfo.fromPlatform();
  sl.registerSingleton<PackageInfo>(packageInfo);

  // Device Info
  final deviceInfo = DeviceInfoPlugin();
  sl.registerSingleton<DeviceInfoPlugin>(deviceInfo);


  // --- Features ---
  
  // Global Logic (Theme & Locale)
  ${_getGlobalInjection(stateType)}

  // @Injection (Do not remove this comment)
}
""";

String _getGlobalInjection(String type) {
  switch (type) {
    case 'bloc':
    case 'cubit':
      return "sl.registerLazySingleton(() => ThemeCubit());\n  sl.registerLazySingleton(() => LocaleCubit());";
    case 'getx':
      return "sl.registerLazySingleton(() => ThemeController());\n  sl.registerLazySingleton(() => LocaleController());";
    case 'provider':
      return "sl.registerLazySingleton(() => ThemeProvider());\n  sl.registerLazySingleton(() => LocaleProvider());";
    case 'riverpod':
      return "// Riverpod handles injection via providers";
    default:
      return "";
  }
}
