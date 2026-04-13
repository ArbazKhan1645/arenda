import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_info.g.dart';

abstract interface class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onStatusChange;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  final http.Client _client;

  NetworkInfoImpl(this._connectivity, this._client);

  static const _timeout = Duration(milliseconds: 700);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();

    if (result.contains(ConnectivityResult.none)) {
      return false;
    }

    return _fastInternetCheck();
  }

  Future<bool> _fastInternetCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('https://1.1.1.1')) // Cloudflare DNS
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<bool> get onStatusChange async* {
    await for (final _ in _connectivity.onConnectivityChanged.distinct()) {
      yield await isConnected;
    }
  }
}

@Riverpod(keepAlive: true)
NetworkInfo networkInfo(Ref ref) {
  return NetworkInfoImpl(
    Connectivity(),
    http.Client(),
  );
}
