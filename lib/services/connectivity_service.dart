import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityResult> _connectivityStreamController =
      StreamController<ConnectivityResult>.broadcast();

  ConnectivityService() {
    // Listen to connectivity changes (returns List<ConnectivityResult>)
    _connectivity.onConnectivityChanged.listen((results) {
      for (var result in results) {
        _connectivityStreamController.add(result);
      }
    });
  }

  Stream<ConnectivityResult> get connectivityStream =>
      _connectivityStreamController.stream;

  /// Check current connectivity (returns first ConnectivityResult from the list)
  Future<ConnectivityResult> checkConnectivity() async {
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    // Return the first result as the "current" connectivity
    return results.isNotEmpty ? results.first : ConnectivityResult.none;
  }

  void dispose() {
    _connectivityStreamController.close();
  }
}
