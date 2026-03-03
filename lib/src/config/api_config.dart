import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> configureApi(String projectName) async {
  printSection('🛡️ API & Security Configuration');

  final activePath = getActiveProjectPath();
  final enableEncryption =
      (ask('Enable End-to-End Encryption (AES-256) for API? (y/n)') ?? 'n')
          .toLowerCase() ==
      'y';

  await loadingSpinner('Generating API core infrastructure', () async {
    final apiDir = Directory(p.join(activePath, 'lib', 'core', 'api'));
    if (!apiDir.existsSync()) {
      apiDir.createSync(recursive: true);
    }

    // 1. Core API Files
    File(
      p.join(apiDir.path, 'dio_factory.dart'),
    ).writeAsStringSync(getDioFactoryTemplate(projectName));
    File(
      p.join(apiDir.path, 'app_interceptor.dart'),
    ).writeAsStringSync(getAppInterceptorTemplate(projectName));
    File(
      p.join(apiDir.path, 'api_service.dart'),
    ).writeAsStringSync(getApiServiceTemplate(projectName));
    File(
      p.join(apiDir.path, 'api_constants.dart'),
    ).writeAsStringSync(getApiConstantsTemplate(projectName));

    // 2. Conditional Encryption Files
    String exports =
        "export 'dio_factory.dart';\nexport 'app_interceptor.dart';\nexport 'api_service.dart';\nexport 'api_constants.dart';";

    if (enableEncryption) {
      File(
        p.join(apiDir.path, 'encryption_service.dart'),
      ).writeAsStringSync(getEncryptionServiceTemplate(projectName));
      File(
        p.join(apiDir.path, 'encryption_interceptor.dart'),
      ).writeAsStringSync(getEncryptionInterceptorTemplate(projectName));
      exports +=
          "\nexport 'encryption_service.dart';\nexport 'encryption_interceptor.dart';";
      printInfo('Generated Encryption Service and Interceptor.');
    }

    // 3. Update Barrel
    File(
      p.join(apiDir.path, 'z_api.dart'),
    ).writeAsStringSync(exports, mode: FileMode.write);
  });

  printSuccess(
    'API infrastructure configured successfully in the active project.',
  );
  if (enableEncryption) {
    printWarning(
      '👉 E2E Encryption enabled. Ensure your backend supports AES decryption.',
    );
  }
  printInfo(
    '👉 Remember to add "sl.registerLazySingleton(() => EncryptionInterceptor());" to injection if used.',
  );
}
