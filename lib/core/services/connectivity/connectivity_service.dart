import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/utils/app_logger.dart';

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier();
});

enum ConnectivityStatus { connected, disconnected }

class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityNotifier() : super(ConnectivityStatus.connected) {
    _startMonitoring();
  }

  Timer? _timer;

  void _startMonitoring() {
    _checkConnectivity();
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkConnectivity(),
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (state != ConnectivityStatus.connected) {
          state = ConnectivityStatus.connected;
          AppLogger.info('🌐 Network: connected');
        }
      }
    } on SocketException catch (_) {
      if (state != ConnectivityStatus.disconnected) {
        state = ConnectivityStatus.disconnected;
        AppLogger.info('🌐 Network: disconnected');
      }
    } on TimeoutException catch (_) {
      if (state != ConnectivityStatus.disconnected) {
        state = ConnectivityStatus.disconnected;
        AppLogger.info('🌐 Network: timed out');
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
