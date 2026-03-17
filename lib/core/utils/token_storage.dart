import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _identityIdKey = 'identity_id';
    static const String _adminTokenKey = 'admin_token'; // new

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int identityId,   // now accepts int
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_identityIdKey, identityId.toString()); // convert to string
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<String?> getIdentityId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_identityIdKey);
  }
 
   static Future<void> saveAdminToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_adminTokenKey, token);
  }

  static Future<String?> getAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_adminTokenKey);
  }

  static Future<void> clearAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_adminTokenKey);
  }
  
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_identityIdKey);
  }
}