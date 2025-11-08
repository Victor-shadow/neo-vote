// lib/api/auth_api.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:neo_vote/core/models/user_model.dart' as app_user; // CORRECTED: Import custom user model with an alias.
import 'package:neo_vote/core/utils/constants.dart';
import 'package:neo_vote/core/utils/failure.dart';
import 'package:neo_vote/core/utils/typedefs.dart';

// REMOVED: Unnecessary import of 'package:firebase_auth/firebase_auth.dart';

class AuthApi {
  final http.Client _client;

  AuthApi({required http.Client client}) : _client = client;

  /// Sends a one-time password (OTP) to the user's phone number.
  FutureEitherVoid sendOtp(String phoneNumber) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/otp/send'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        return right(null);
      } else {
        return left(Failure('Server error: ${response.statusCode}'));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  /// Verifies the OTP and returns a JWT token on success.
  FutureEither<String> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/otp/verify'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String;
        return right(token);
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Invalid OTP or server error.';
        return left(Failure(error));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  /// Fetches the user's profile data using their JWT token.
  // CORRECTED: Return type is now the aliased custom user model.
  FutureEither<app_user.User> getUserProfile(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/profile'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // CORRECTED: Using the aliased `app_user.User.fromJson` to parse the response.
        // The API might return the user data nested under a 'user' key.
        final userData = data['user'] as Map<String, dynamic>? ?? data;
        return right(app_user.User.fromJson(userData));
      } else {
        return left(Failure('Failed to fetch user profile. Your session may have expired.'));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }
}
