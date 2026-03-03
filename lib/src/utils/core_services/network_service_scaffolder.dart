import 'package:tools/tools.dart';

Future<void> scaffoldNetworkService() async {
  printSection('Network Service Scaffolder');

  await runCommand('flutter', [
    'pub',
    'add',
    'connectivity_plus',
  ], loadingMessage: 'Adding connectivity_plus dependency');

  await loadingSpinner(
    'Generating NetworkService and wiring injection',
    () async {
      final serviceFile = File('lib/core/services/network_service.dart');
      if (!serviceFile.parent.existsSync()) {
        serviceFile.parent.createSync(recursive: true);
      }

      serviceFile.writeAsStringSync("""
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final Connectivity _connectivity = Connectivity();

  static Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map((results) => _hasConnection(results));

  static Future<bool> get hasConnection async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  static bool _hasConnection(List<ConnectivityResult> results) {
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }
}
""");

      updateServiceBarrel('network_service.dart');
      await wireCoreInjection('NetworkService');
    },
  );

  printSuccess('NetworkService ready! Monitor connectivity reactively.');
}
