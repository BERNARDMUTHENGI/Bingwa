import 'user.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // The response has a top-level "data" field containing tokens and user
    final data = json['data'];
    return AuthResponse(
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
      user: User.fromJson(data['user']),
    );
  }
}