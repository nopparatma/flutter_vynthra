import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vynthra/app/env.dart';

/// Error returned by vynthra_service or raised while reaching it.
class ApiException implements Exception {
  final int? statusCode;
  final String code;
  final String message;

  ApiException({this.statusCode, required this.code, required this.message});

  @override
  String toString() => 'ApiException($code): $message';
}

/// HTTP client for vynthra_service.
class ApiClient {
  final String baseUrl;
  final http.Client _http;

  ApiClient({String? baseUrl, http.Client? httpClient})
      : baseUrl = baseUrl ?? Env.apiBaseUrl,
        _http = httpClient ?? http.Client();

  Uri _uri(String path) {
    if (baseUrl.isEmpty) {
      throw ApiException(code: 'not_configured', message: 'API_BASE_URL is not set for this build');
    }
    return Uri.parse('$baseUrl$path');
  }

  Future<List<Map<String, dynamic>>> getList(String path) async {
    final response = await _http.get(_uri(path)).timeout(const Duration(seconds: 30));
    final body = _decode(response);
    return (body as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> payload, {Duration timeout = const Duration(seconds: 150)}) async {
    final response = await _http
        .post(
          _uri(path),
          headers: {'content-type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(timeout);
    return _decode(response) as Map<String, dynamic>;
  }

  dynamic _decode(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300 && body != null) {
      return body;
    }

    final error = body is Map ? body['error'] : null;
    throw ApiException(
      statusCode: response.statusCode,
      code: error is Map ? '${error['code']}' : 'http_${response.statusCode}',
      message: error is Map ? '${error['message']}' : 'Unexpected response from server',
    );
  }

  void close() => _http.close();
}
