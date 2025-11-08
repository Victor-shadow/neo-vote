// lib/core/models/user_model.dart

import 'package:equatable/equatable.dart';

/// Represents the application's user.
///
/// This model is decoupled from any specific authentication provider (like Firebase)
/// and is designed to work with the custom backend API. It holds user-specific
/// data that is fetched after a successful login.
class User extends Equatable {
    /// The unique identifier for the user (e.g., UUID from your database).
    final String id;

    /// The user's full name.
    final String name;

    /// The user's phone number, used for login.
    final String phoneNumber;

    const User({
        required this.id,
        required this.name,
        required this.phoneNumber,
    });

    /// The properties used by `Equatable` to determine if two `User` instances are the same.
    @override
    List<Object?> get props => [id, name, phoneNumber];

    /// Creates a `User` instance from a JSON map.
    ///
    /// This factory is essential for deserializing the user profile data
    /// returned by the `/auth/profile` endpoint. It includes null-safety checks
    /// and default values to prevent runtime errors.
    factory User.fromJson(Map<String, dynamic> json) {
        return User(
            id: json['id'] as String? ?? '',
            name: json['name'] as String? ?? 'No Name Provided',
            phoneNumber: json['phoneNumber'] as String? ?? 'No Phone Number',
        );
    }
}
