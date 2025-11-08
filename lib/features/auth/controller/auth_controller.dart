// lib/features/auth/controller/auth_controller.dart

import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // CORRECTED: Added missing import for StateNotifier
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:neo_vote/api/auth_api.dart';
import 'package:neo_vote/core/models/user_model.dart';

// --- State Definitions ---

/// An enum representing the various states of authentication.
enum AuthStatus {
  /// The initial state before any auth action has been taken.
  initial,

  /// An asynchronous operation is in progress (e.g., API call).
  loading,

  /// The user has successfully authenticated and their profile is loaded.
  authenticated,

  /// The user is not authenticated.
  unauthenticated,

  /// The system has sent an OTP and is waiting for the user to enter it.
  requiresOtp,

  /// An error occurred during an authentication process.
  error,
}

/// The state class for authentication, managed by [AuthController].
///
/// It holds the current [AuthStatus], the authenticated [User] object (if any),
/// and an optional error message. It uses `Equatable` for efficient state updates.
class AuthState extends Equatable {
  /// The current status of the authentication flow.
  final AuthStatus status;

  /// The authenticated user's data. Null if not authenticated.
  final User? user;

  /// An error message, present only when the status is [AuthStatus.error].
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  /// Creates a copy of the current state with updated values.
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    bool clearUser = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}


// --- Providers ---

/// Provider for the secure storage instance.
final _secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

/// Provider for the HTTP client.
final _httpClientProvider = Provider((ref) => http.Client());

/// Provider for the [AuthApi] instance, which handles auth-related network requests.
final authApiProvider = Provider(
      (ref) => AuthApi(client: ref.watch(_httpClientProvider)),
);

/// The main provider for the [AuthController] and its [AuthState].
///
/// This is the central point for the UI to interact with and listen to
/// authentication state changes.
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
      (ref) => AuthController(
    ref.watch(authApiProvider),
    ref.watch(_secureStorageProvider),
  ),
);


// --- Controller ---

/// Manages the application's authentication logic and state.
///
/// This controller orchestrates the authentication flow, interacting with the
/// [AuthApi] for network requests and [FlutterSecureStorage] to persist the
/// user's session token.
class AuthController extends StateNotifier<AuthState> {
  final AuthApi _authApi;
  final FlutterSecureStorage _secureStorage;
  static const _tokenKey = 'auth_token';

  // CORRECTED: Constructor no longer uses named parameters to match provider
  AuthController(this._authApi, this._secureStorage)
      : super(const AuthState(status: AuthStatus.initial)) {
    _initializeApp();
  }

  /// Initializes the controller by checking for a saved session token.
  Future<void> _initializeApp() async {
    state = state.copyWith(status: AuthStatus.loading);
    final token = await _secureStorage.read(key: _tokenKey);

    if (token != null) {
      await _loadUserProfile(token);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// Attempts to log in by fetching the user profile with a saved token.
  Future<void> loginWithBiometricToken() async {
    state = state.copyWith(status: AuthStatus.loading);
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No saved session found for biometric login.',
      );
      // Allow the UI to show the error briefly before resetting
      await Future.delayed(const Duration(milliseconds: 50));
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    await _loadUserProfile(token);
  }

  /// Initiates the login process by requesting an OTP for the given phone number.
  Future<void> loginWithPhoneNumber(String phoneNumber) async {
    state = state.copyWith(status: AuthStatus.loading, clearErrorMessage: true);
    final result = await _authApi.sendOtp(phoneNumber);

    result.fold(
          (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message),
          (_) => state = state.copyWith(status: AuthStatus.requiresOtp),
    );
  }

  /// Verifies the provided OTP and phone number.
  Future<void> verifyOtp(String phoneNumber, String otp) async {
    state = state.copyWith(status: AuthStatus.loading, clearErrorMessage: true);
    final result = await _authApi.verifyOtp(phoneNumber, otp);

    result.fold(
          (failure) {
        state = state.copyWith(status: AuthStatus.requiresOtp, errorMessage: failure.message);
      },
          (token) async {
        await _secureStorage.write(key: _tokenKey, value: token);
        await _loadUserProfile(token);
      },
    );
  }

  /// Fetches the user profile using a token and updates the state.
  Future<void> _loadUserProfile(String token) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _authApi.getUserProfile(token);

    result.fold(
          (failure) async {
        await logout();
        state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message);
      },
          (user) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user, clearErrorMessage: true);
      },
    );
  }

  /// Logs the user out by deleting the session token and resetting the state.
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
