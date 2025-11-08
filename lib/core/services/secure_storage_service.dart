// lib/core/services/secure_storage_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:neo_vote/core/utils/constants.dart';

// Provider for the service
final secureStorageServiceProvider = Provider((ref) => SecureStorageService());

class SecureStorageService {
    final _storage = const FlutterSecureStorage();

    Future<void> saveAuthToken(String token) async {
        await _storage.write(key: AppConstants.authTokenKey, value: token);
    }

    Future<String?> getAuthToken() async {
        return await _storage.read(key: AppConstants.authTokenKey);
    }

    Future<void> deleteAuthToken() async {
        await _storage.delete(key: AppConstants.authTokenKey);
    }

    Future<void> saveThemePreference(String theme) async {
        await _storage.write(key: AppConstants.themePreferenceKey, value: theme);
    }

    Future<String?> getThemePreference() async {
        return await _storage.read(key: AppConstants.themePreferenceKey);
    }
}
