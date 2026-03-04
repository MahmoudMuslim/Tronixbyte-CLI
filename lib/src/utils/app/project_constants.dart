final List<String> baseDeps = [
  'cupertino_icons',
  'skeletonizer',
  'cached_network_image',
  'flutter_secure_storage',
  'permission_handler',
  'go_router',
  'get_it',
  'easy_localization',
  'intl',
  'equatable',
  'json_annotation',
  'equatable_annotations',
  'path_provider',
  'path',
  'package_info_plus',
  'device_info_plus',
  'wakelock_plus',
  'device_preview_plus',
  'iconify_flutter_plus',
  'colorful_iconify_flutter',
  'share_plus',
  'url_launcher',
  'flutter_svg',
  'feedback',
  'logger',
  'dartz',
  'flutter_dotenv',
];

final List<String> baseDevDeps = [
  'build_runner',
  'json_serializable',
  'equatable_gen',
  'go_router_builder',
  'flutter_native_splash',
  'package_rename',
  'icons_launcher',
  'mocktail',
];
final List<String> baseOverrideDeps = ['json_annotation'];

final List<String> apiDeps = ['dio', 'retrofit', 'pretty_dio_logger'];
final List<String> apiDevDeps = ['retrofit_generator', 'build_runner'];

final List<String> databaseDeps = [
  'drift',
  'drift_flutter',
  'path_provider',
  'path',
];
final List<String> databaseDevDeps = ['drift_dev', 'build_runner'];

final Map<String, List<String>> stateManagementDeps = {
  'bloc': ['flutter_bloc', 'hydrated_bloc', 'replay_bloc', 'bloc_concurrency'],
  'cubit': ['flutter_bloc', 'hydrated_bloc', 'replay_bloc', 'bloc_concurrency'],
  'riverpod': ['hooks_riverpod', 'flutter_hooks', 'riverpod_annotation'],
  'getx': ['get_storage', 'get'],
  'provider': ['provider'],
};
final Map<String, List<String>> stateManagementDevDeps = {
  'bloc': ['bloc_test'],
  'cubit': ['bloc_test'],
  'riverpod': ['riverpod_generator'],
  'getx': [],
  'provider': [],
};

final List<String> firebaseBaseDeps = ['firebase_core'];
final Map<String, String> firebaseServices = {
  'firebase_core': 'Core Engine (Mandatory)',
  'firebase_auth': 'Identity & Auth',
  'firebase_ui_auth': 'FlutterFire UI for Auth',
  'cloud_firestore': 'NoSQL Cloud Database',
  'firebase_ui_firestore': 'FlutterFire UI for Firestore',
  'firebase_database': 'Realtime Database',
  'firebase_ui_database': 'FlutterFire UI for Realtime Database',
  'firebase_messaging': 'Push Notifications',
  'firebase_in_app_messaging': 'In-App Messaging',
  'firebase_storage': 'Cloud Asset Storage',
  'firebase_analytics': 'Behavioral Analytics',
  'firebase_crashlytics': 'Real-time Error Reporting',
  'firebase_performance': 'App Performance Monitoring',
  'firebase_remote_config': 'Dynamic App Configuration',
  'firebase_app_check': 'Security & Attestation',
};
