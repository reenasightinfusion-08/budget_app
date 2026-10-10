import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/core/network/api_exception.dart';

/// Opens the Google account picker and returns the Google ID token for the backend to verify.
class GoogleAuthService {
  bool initialized = false;

  Future<String> fetchIdToken() async {
    if (AppConfig.googleServerClientId.isEmpty) {
      debugPrint('Google sign-in: AppConfig.googleServerClientId is empty. Paste the Web client ID.');
      throw const ApiException('Google sign-in is not set up yet.');
    }

    final googleSignIn = GoogleSignIn.instance;
    if (!initialized) {
      await googleSignIn.initialize(serverClientId: AppConfig.googleServerClientId);
      initialized = true;
    }

    try {
      final account = await googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw const ApiException('Google did not return a sign-in token.');
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const ApiException('Google sign-in was cancelled.');
      }
      debugPrint('Google sign-in: ${e.code} | ${e.description} | ${e.details}');
      throw const ApiException('Google sign-in failed. Please try again.');
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('Google sign-out error: $e');
    }
  }
}
