String getAuthCubitTemplate(String projectName, String socialMethodsStr) {
  return """
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
""";
}

String getAuthRiverpodTemplate(String projectName, String socialMethodsStr) {
  return """
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
""";
}

String getAuthGetxControllerTemplate(
  String projectName,
  String socialMethodsStr,
) {
  return """
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
""";
}

String getAuthProviderTemplate(String projectName, String socialMethodsStr) {
  return """
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
""";
}

String getSignInWithFacebookTemplate() {
  return """
Future<void> signInWithFacebook() async {
  final LoginResult result = await FacebookAuth.instance.login();
  if (result.status == LoginStatus.success) {
    final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
    await FirebaseAuth.instance.signInWithCredential(credential);
  }
}""";
}

String getSignInWithAppleTemplate() {
  return """
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
}""";
}

String getSignInWithGoogleTemplate() {
  return """
Future<void> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
  if (googleAuth != null) {
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken);
    await FirebaseAuth.instance.signInWithCredential(credential);
  }
}""";
}
