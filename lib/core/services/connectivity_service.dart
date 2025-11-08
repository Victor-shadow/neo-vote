import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// A StreamProvider that directly exposes the connectivity change stream.
// This is the most efficient way to listen for connectivity status in the UI.
final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((results) => results.first);
});

// A simple service class in case you need to imperatively check connectivity.
final connectivityServiceProvider = Provider((ref) => ConnectivityService());

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Checks the current connectivity status once.
  Future<ConnectivityResult> get currentConnectivity async {
    final results = await _connectivity.checkConnectivity();
    return results.first;
  }

  /// A stream that emits the connectivity status whenever it changes.
  Stream<ConnectivityResult> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) => results.first);
  }
}
