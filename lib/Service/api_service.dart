import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String? token;

  ApiService({this.token});

  final String baseUrl = dotenv.env['API_KEY']!;

  // GET
  Future<http.Response> get(String endpoint) async {
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(),
    );
  }

  // POST
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // PATCH
  Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body}) async {
    return await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // DELETE
  Future<http.Response> delete(String endpoint) async {
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(),
    );
  }

  // Méthode privée pour construire les headers avec ou sans token
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
