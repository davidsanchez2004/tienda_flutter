class User {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final String? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.role = 'customer',
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'customer',
      createdAt: json['created_at'],
    );
  }
}

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final int? expiresAt;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiresAt: json['expires_at'],
    );
  }
}
