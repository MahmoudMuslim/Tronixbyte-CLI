import 'package:tools/tools.dart';

Future<void> configureApi(String projectName) async {
  printSection('🛡️ API & Security Configuration');

  final enableEncryption =
      (ask('Enable End-to-End Encryption (AES-256) for API? (y/n)') ?? 'n')
          .toLowerCase() ==
      'y';

  await loadingSpinner('Generating API core infrastructure', () async {
    final apiDir = Directory('lib/core/api');
    if (!apiDir.existsSync()) {
      apiDir.createSync(recursive: true);
    }

    // 1. Core API Files
    File(
      'lib/core/api/dio_factory.dart',
    ).writeAsStringSync(getDioFactoryTemplate(projectName));
    File(
      'lib/core/api/app_interceptor.dart',
    ).writeAsStringSync(getAppInterceptorTemplate(projectName));
    File(
      'lib/core/api/api_service.dart',
    ).writeAsStringSync(getApiServiceTemplate(projectName));
    File(
      'lib/core/api/api_constants.dart',
    ).writeAsStringSync(getApiConstantsTemplate(projectName));

    // 2. Conditional Encryption Files
    String exports =
        "export 'dio_factory.dart';\nexport 'app_interceptor.dart';\nexport 'api_service.dart';\nexport 'api_constants.dart';";

    if (enableEncryption) {
      File(
        'lib/core/api/encryption_service.dart',
      ).writeAsStringSync(getEncryptionServiceTemplate(projectName));
      File(
        'lib/core/api/encryption_interceptor.dart',
      ).writeAsStringSync(getEncryptionInterceptorTemplate(projectName));
      exports +=
          "\nexport 'encryption_service.dart';\nexport 'encryption_interceptor.dart';";
      printInfo('Generated Encryption Service and Interceptor.');
    }

    // 3. Update Barrel
    File(
      'lib/core/api/z_api.dart',
    ).writeAsStringSync(exports, mode: FileMode.write);
  });

  printSuccess('API infrastructure configured successfully.');
  if (enableEncryption) {
    printWarning(
      '👉 E2E Encryption enabled. Ensure your backend supports AES decryption.',
    );
  }
  printInfo(
    '👉 Remember to add "sl.registerLazySingleton(() => EncryptionInterceptor());" to injection if used.',
  );
}
