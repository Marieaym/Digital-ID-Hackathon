import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  String? token;

  ApiClient(this.baseUrl);

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    print('Request: POST $baseUrl$path');
    print('Headers: ${{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    }}');
    print('Body: ${jsonEncode(body)}');

    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print('Response: ${res.statusCode}, Body: ${res.body}');

    if (res.statusCode >= 400) throw Exception('HTTP ${res.statusCode}: ${res.body}');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getList(String path) async {
    final res = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: { if (token != null) 'Authorization': 'Bearer $token' },
    );
    if (res.statusCode >= 400) throw Exception('HTTP ${res.statusCode}: ${res.body}');
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getMap(String path) async {
    final res = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: { if (token != null) 'Authorization': 'Bearer $token' },
    );
    if (res.statusCode >= 400) throw Exception('HTTP ${res.statusCode}: ${res.body}');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
