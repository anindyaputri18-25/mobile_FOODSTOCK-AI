import 'dart:convert';
import 'package:http/http.dart' as http;

const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000');

class ApiClient {
  static String? token;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static dynamic _handle(http.Response r) {
    final body = r.body.isEmpty ? null : jsonDecode(r.body);
    if (r.statusCode >= 200 && r.statusCode < 300) return body;
    final msg = (body is Map && body['message'] != null) ? body['message'] : 'Error ${r.statusCode}';
    throw Exception(msg);
  }

  static Future<dynamic> get(String path) async =>
      _handle(await http.get(Uri.parse('$apiUrl$path'), headers: _headers));

  static Future<dynamic> post(String path, Map<String, dynamic> data) async =>
      _handle(await http.post(Uri.parse('$apiUrl$path'), headers: _headers, body: jsonEncode(data)));
}