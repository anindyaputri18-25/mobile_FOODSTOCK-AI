import 'dart:convert';
import 'package:http/http.dart' as http;

const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000');

/// Error dari API. [detail] dipakai oleh layar untuk menampilkan pesan.
class ApiException implements Exception {
  ApiException(this.detail, {this.statusCode});
  final String detail;
  final int? statusCode;

  @override
  String toString() => detail;
}

class ApiClient {
  static String? token;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static dynamic _handle(http.Response r) {
    dynamic body;
    try {
      body = r.body.isEmpty ? null : jsonDecode(r.body);
    } catch (_) {
      body = null;
    }
    if (r.statusCode >= 200 && r.statusCode < 300) return body;
    final msg = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : 'Terjadi kesalahan (${r.statusCode})';
    throw ApiException(msg, statusCode: r.statusCode);
  }

  static Future<dynamic> _send(Future<http.Response> Function() call) async {
    try {
      return _handle(await call());
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Tidak dapat terhubung ke server. Periksa API_URL dan jaringan.');
    }
  }

  static Future<dynamic> get(String path) =>
      _send(() => http.get(Uri.parse('$apiUrl$path'), headers: _headers));

  static Future<dynamic> post(String path, Map<String, dynamic> data) => _send(
      () => http.post(Uri.parse('$apiUrl$path'), headers: _headers, body: jsonEncode(data)));
}