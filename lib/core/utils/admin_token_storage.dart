import 'package:shared_preferences/shared_preferences.dart';

class AdminTokenStorage {
  static const String _accessTokenKey = 'admin_access_token';
  static const String _refreshTokenKey = 'admin_refresh_token';
  static const String _identityIdKey = 'admin_identity_id';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int identityId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_identityIdKey, identityId.toString());
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_identityIdKey);
  }
}