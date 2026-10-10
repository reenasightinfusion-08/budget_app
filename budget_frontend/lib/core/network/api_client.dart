import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/core/network/api_exception.dart';

/// Talks to the Budgie backend. Returns the `data` object of every successful
/// response and throws [ApiException] with the server's message otherwise.
class ApiClient {
  static const String tokenKey = 'auth_token';
  static const Duration timeout = Duration(seconds: 30);

  String? token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(tokenKey);
  }

  Future<void> saveToken(String value) async {
    token = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, value);
  }

  Future<void> clearToken() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  Future<Map<String, dynamic>> get(String path) => send('GET', path);

  Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) =>
      send('POST', path, body);

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) =>
      send('PATCH', path, body);

  Future<Map<String, dynamic>> delete(String path) => send('DELETE', path);

  Future<Map<String, dynamic>> send(String method, String path, [Map<String, dynamic>? body]) async {
    final request = http.Request(method, Uri.parse('${AppConfig.apiBaseUrl}$path'));
    request.headers['Content-Type'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) request.body = jsonEncode(body);

    try {
      final response = await http.Response.fromStream(await request.send().timeout(timeout));
      return parse(response, '$method $path');
    } on SocketException catch (e) {
      debugPrint('API $method $path: network error $e');
      throw const ApiException('No internet connection. Check it and try again.');
    } on http.ClientException catch (e) {
      debugPrint('API $method $path: client error $e');
      throw const ApiException('No internet connection. Check it and try again.');
    } on TimeoutException {
      debugPrint('API $method $path: timed out');
      throw const ApiException('The server took too long to respond. Try again.');
    }
  }

  Map<String, dynamic> parse(http.Response response, String label) {
    if (response.statusCode >= 200 && response.statusCode < 300 && response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    Map<String, dynamic> body;
    try {
      final decoded = jsonDecode(response.body);
      body = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on FormatException {
      debugPrint('API $label: unexpected body ${response.statusCode}: ${response.body}');
      throw ApiException('Unexpected response from the server.', statusCode: response.statusCode);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('API $label: ${response.statusCode} ${response.body}');
      throw ApiException(
        body['message'] as String? ?? 'Something went wrong. Please try again.',
        statusCode: response.statusCode,
      );
    }
    return (body['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
  }
}
