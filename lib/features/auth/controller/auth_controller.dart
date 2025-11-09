import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:neo_vote/api/auth_api.dart';
import 'package:neo_vote/core/models/user_model.dart' as app_user;

// --- State Definitions ---

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  requiresOtp,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final app_user.User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    app_user.User? user,
    bool clearUser = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

// --- Providers ---

final _secureStorageProvider = Provider((ref) => const FlutterSecureStorage());
final _httpClientProvider = Provider((ref) => http.Client());

final authApiProvider = Provider(
  (ref) => AuthApi(client: ref.watch(_httpClientProvider)),
);

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  late final AuthApi _authApi = ref.watch(authApiProvider);
  late final FlutterSecureStorage _secureStorage =
      ref.watch(_secureStorageProvider);
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  static const _tokenKey = 'auth_token';

  @override
  AuthState build() {
    Future.microtask(() => _initializeApp());
    return const AuthState(status: AuthStatus.initial);
  }

  Future<void> _initializeApp() async {
    state = state.copyWith(status: AuthStatus.loading);
    final token = await _secureStorage.read(key: _tokenKey);
    if (token != null) {
      await _loadUserProfile(token);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> loginWithBiometricToken() async {
    state = state.copyWith(status: AuthStatus.loading);
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) {
      state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'No saved session found for the biometric login ');
      await Future.delayed(const Duration(milliseconds: 50));
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    await _loadUserProfile(token);
  }

  Future<void> loginWithPhoneNumber(String phoneNumber) async {
    state = state.copyWith(status: AuthStatus.loading, clearErrorMessage: true);
    final result = await _authApi.sendOtp(phoneNumber);
    result.fold(
      (failure) => state = state.copyWith(
          status: AuthStatus.error, errorMessage: failure.message),
      (_) => state = state.copyWith(status: AuthStatus.requiresOtp),
    );
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    state = state.copyWith(status: AuthStatus.loading, clearErrorMessage: true);
    final result = await _authApi.verifyOtp(phoneNumber, otp);
    result.fold(
      (failure) => state = state.copyWith(
          status: AuthStatus.requiresOtp, errorMessage: failure.message),
      (token) async {
        await _secureStorage.write(key: _tokenKey, value: token);
        await _loadUserProfile(token);
      },
    );
  }

  Future<void> loginWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearErrorMessage: true);
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final token = await userCredential.user!.getIdToken();
      await _secureStorage.write(key: _tokenKey, value: token!);
      await _loadUserProfile(token);
    } catch (e) {
      state =
          state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signupWithEmail(
      String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearErrorMessage: true);
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await userCredential.user!.updateDisplayName(name);
      final token = await userCredential.user!.getIdToken();
      await _secureStorage.write(key: _tokenKey, value: token!);
      await _loadUserProfile(token);
    } catch (e) {
      state =
          state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, clearErrorMessage: true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final token = await userCredential.user!.getIdToken();
      await _secureStorage.write(key: _tokenKey, value: token!);
      await _loadUserProfile(token);
    } catch (e) {
      state =
          state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> _loadUserProfile(String token) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _authApi.getUserProfile(token);
    result.fold(
      (failure) async {
        await logout();
        state = state.copyWith(
            status: AuthStatus.error, errorMessage: failure.message);
      },
      (user) => state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearErrorMessage: true),
    );
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    await _secureStorage.delete(key: _tokenKey);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
