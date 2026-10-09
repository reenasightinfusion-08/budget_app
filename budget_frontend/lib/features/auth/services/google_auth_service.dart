import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/features/auth/models/user_model.dart';
import 'package:budget_frontend/features/auth/services/auth_exception.dart';

/// Signs in with Google, then exchanges the Google ID token for the backend's account.
class GoogleAuthService {
  bool initialized = false;

  /// JWT returned by the backend; send it as `Authorization: Bearer` on later calls.
  String? token;

  Future<UserModel> signIn() async {
    final idToken = await fetchIdToken();
    final response = await postIdToken(idToken);
    final body = decodeBody(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('Google sign-in: backend replied ${response.statusCode}: ${response.body}');
      throw AuthException(body['message'] as String? ?? 'Google sign-in failed. Please try again.');
    }

    final data = body['data'] as Map<String, dynamic>;
    token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    return UserModel(email: user['email'] as String);
  }

  Future<String> fetchIdToken() async {
    if (AppConfig.googleServerClientId.isEmpty) {
      debugPrint('Google sign-in: AppConfig.googleServerClientId is empty. Paste the Web client ID.');
      throw const AuthException('Google sign-in is not set up yet.');
    }

    final googleSignIn = GoogleSignIn.instance;
    if (!initialized) {
      await googleSignIn.initialize(serverClientId: AppConfig.googleServerClientId);
      initialized = true;
    }

    try {
      final account = await googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw const AuthException('Google did not return a sign-in token.');
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('Google sign-in was cancelled.');
      }
      debugPrint('Google sign-in: ${e.code} | ${e.description} | ${e.details}');
      throw const AuthException('Google sign-in failed. Please try again.');
    }
  }

  Future<http.Response> postIdToken(String idToken) async {
    try {
      return await http
          .post(
            Uri.parse('${AppConfig.apiBaseUrl}/auth/google'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': idToken}),
          )
          .timeout(const Duration(seconds: 20));
    } on SocketException catch (e) {
      debugPrint('Google sign-in: network error $e');
      throw const AuthException('No internet connection. Check it and try again.');
    } on TimeoutException {
      debugPrint('Google sign-in: request to ${AppConfig.apiBaseUrl} timed out');
      throw const AuthException('The server took too long to respond. Try again.');
    }
  }

  Map<String, dynamic> decodeBody(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const AuthException('Unexpected response from the server.');
    }
  }
}
