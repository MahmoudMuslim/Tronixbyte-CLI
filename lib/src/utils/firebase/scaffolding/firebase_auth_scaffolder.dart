import 'package:path/path.dart' as p;
import 'package:tools/tools.dart';

Future<void> scaffoldAuthLogic(
  String projectName,
  String stateType,
  String pubspec, {
  List<String>? enabledProviders,
}) async {
  if (!pubspec.contains('firebase_auth')) return;

  final activePath = getActiveProjectPath();
  printInfo('Scaffolding global Auth logic ($stateType) in $activePath...');

  final authDir = Directory(
    p.join(activePath, 'lib', 'core', 'services', 'auth'),
  );
  if (!authDir.existsSync()) authDir.createSync(recursive: true);

  final List<String> socialMethods = [];
  if (enabledProviders != null) {
    if (enabledProviders.contains('google')) {
      socialMethods.add(getSignInWithGoogleTemplate());
    }
    if (enabledProviders.contains('apple')) {
      socialMethods.add(getSignInWithAppleTemplate());
    }
    if (enabledProviders.contains('facebook')) {
      socialMethods.add(getSignInWithFacebookTemplate());
    }
  }

  final String socialMethodsStr = socialMethods.join('\n\n');

  await loadingSpinner('Generating Auth logic files', () async {
    if (stateType == 'bloc' || stateType == 'cubit') {
      final logicFile = File(p.join(authDir.path, 'auth_cubit.dart'));
      logicFile.writeAsStringSync(
        getAuthCubitTemplate(projectName, socialMethodsStr),
      );
    } else if (stateType == 'riverpod') {
      final logicFile = File(p.join(authDir.path, 'auth_provider.dart'));
      logicFile.writeAsStringSync(
        getAuthRiverpodTemplate(projectName, socialMethodsStr),
      );
    } else if (stateType == 'getx') {
      final logicFile = File(p.join(authDir.path, 'auth_controller.dart'));
      logicFile.writeAsStringSync(
        getAuthGetxControllerTemplate(projectName, socialMethodsStr),
      );
    } else if (stateType == 'provider') {
      final logicFile = File(p.join(authDir.path, 'auth_provider.dart'));
      logicFile.writeAsStringSync(
        getAuthProviderTemplate(projectName, socialMethodsStr),
      );
    }

    // Update barrel
    final barrelFile = File(p.join(authDir.path, 'z_auth.dart'));
    final logicFileName = stateType == 'getx'
        ? 'auth_controller.dart'
        : (stateType == 'riverpod' ? 'auth_provider.dart' : 'auth_cubit.dart');

    if (!barrelFile.existsSync()) {
      barrelFile.writeAsStringSync("export '$logicFileName';\n");
    } else {
      String content = barrelFile.readAsStringSync();
      if (!content.contains(logicFileName)) {
        barrelFile.writeAsStringSync(
          "${content.trim()}\nexport '$logicFileName';\n",
        );
      }
    }
  });

  printSuccess('Auth logic scaffolded successfully.');
}
