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
      socialMethods.add("""
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    if (googleAuth != null) {
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken);
      await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }""");
    }
    if (enabledProviders.contains('apple')) {
      socialMethods.add("""
  Future<void> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: credential.identityToken,
      rawNonce: credential.nonce);
    await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }""");
    }
    if (enabledProviders.contains('facebook')) {
      socialMethods.add("""
  Future<void> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
      await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }""");
    }
  }

  final String socialMethodsStr = socialMethods.join('\n\n');

  await loadingSpinner('Generating Auth logic files', () async {
    if (stateType == 'bloc' || stateType == 'cubit') {
      final logicFile = File(p.join(authDir.path, 'auth_cubit.dart'));
      logicFile.writeAsStringSync("""
import 'package:$projectName/$projectName.dart';

class AuthCubit extends Cubit<User?> {
  AuthCubit() : super(FirebaseAuth.instance.currentUser) {
    FirebaseAuth.instance.authStateChanges().listen((user) => emit(user));
  }

  bool get isAuthenticated => state != null;
  String? get userId => state?.uid;
  
  Future<void> logout() => FirebaseAuth.instance.signOut();

$socialMethodsStr
}
""");
    } else if (stateType == 'riverpod') {
      final logicFile = File(p.join(authDir.path, 'auth_provider.dart'));
      logicFile.writeAsStringSync("""
import 'package:$projectName/$projectName.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final authNotifierProvider = Provider((ref) => AuthNotifier());

class AuthNotifier {
  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;
  String? get userId => FirebaseAuth.instance.currentUser?.uid;
  Future<void> logout() => FirebaseAuth.instance.signOut();

$socialMethodsStr
}
""");
    } else if (stateType == 'getx') {
      final logicFile = File(p.join(authDir.path, 'auth_controller.dart'));
      logicFile.writeAsStringSync("""
import 'package:$projectName/$projectName.dart';

class AuthController extends GetxController {
  final _user = Rxn<User>();
  User? get user => _user.value;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(FirebaseAuth.instance.authStateChanges());
  }

  bool get isAuthenticated => user != null;
  String? get userId => user?.uid;
  Future<void> logout() => FirebaseAuth.instance.signOut();

$socialMethodsStr
}
""");
    } else if (stateType == 'provider') {
      final logicFile = File(p.join(authDir.path, 'auth_provider.dart'));
      logicFile.writeAsStringSync("""
import 'package:$projectName/$projectName.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  bool get isAuthenticated => _user != null;
  String? get userId => _user?.uid;
  Future<void> logout() => FirebaseAuth.instance.signOut();

$socialMethodsStr
}
""");
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
