import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper around `connectivity_plus` so the repository can ask a single
/// question — "are we online?" — without depending on the package's API shape.
class ConnectivityService {
  final Connectivity _connectivity;
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Returns true if the device is connected to any network (wifi/mobile/etc).
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Live stream of online/offline changes for UI banners.
  Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));
}
