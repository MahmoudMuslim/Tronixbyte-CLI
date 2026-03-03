import 'package:tools/tools.dart';

Future<void> manageFirebaseServices() async {
  printSection('Firebase Services Hub');

  final List<String> toAdd = [];
  bool authEnabled = false;

  // Use centralized firebaseServices from utils.dart
  firebaseServices.forEach((key, desc) {
    final add = (ask('Add $key ($desc)? (y/n)') ?? 'n').toLowerCase() == 'y';
    if (add) {
      toAdd.add(key);
      if (key == 'firebase_auth') authEnabled = true;
    }
  });

  final List<String> authProviders = [];
  if (authEnabled) {
    print('\n$blue$bold👤 Configure Auth Providers$reset');
    final providers = {
      'email': 'Email/Password',
      'phone': 'Phone Number (SMS)',
      'anonymous': 'Anonymous (Guest)',
      'google': 'Google Sign-In',
      'apple': 'Apple Sign-In',
      'facebook': 'Facebook Login',
      'twitter': 'Twitter (X) Login',
    };

    providers.forEach((id, label) {
      final enable =
          (ask('  - Enable $label? (y/n)') ?? (id == 'email' ? 'y' : 'n'))
              .toLowerCase() ==
          'y';
      if (enable) {
        authProviders.add(id);
        // Add specific packages for social providers
        if (id == 'google') toAdd.add('google_sign_in');
        if (id == 'facebook') toAdd.add('flutter_facebook_auth');
        if (id == 'apple') toAdd.add('sign_in_with_apple');
        if (id == 'twitter') toAdd.add('twitter_login');
      }
    });
  }

  if (toAdd.isNotEmpty) {
    // Include firebaseBaseDeps (firebase_core) as the mandatory foundation
    final uniquePackages = {...firebaseBaseDeps, ...toAdd}.toList();

    await runCommand('flutter', [
      'pub',
      'add',
      ...uniquePackages,
    ], loadingMessage: 'Installing selected Firebase packages');

    // Auto-trigger scaffolding to make services workable
    await scaffoldFirebaseIntegration(enabledProviders: authProviders);

    printSuccess('Firebase services installed and integrated successfully!');
    printInfo(
      'PRO TIP: Run "Configure FlutterFire CLI" to finalize your platform setup.',
    );
  } else {
    printInfo('No services selected. No changes made.');
  }
}
