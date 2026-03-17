import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../models/auth_response.dart';
import '../models/user.dart'; // import User model
import '../../../core/utils/token_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  bool _isLoading = false;
  String? _error;
  AuthResponse? _authResponse;
  User? _currentUser; // added

  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthResponse? get authResponse => _authResponse;
  User? get currentUser => _currentUser ?? _authResponse?.user; // added

  Future<bool> register({
    required String email,
    required String phone,
    required String password,
    required String fullName,
    required String device,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.register(
        email: email,
        phone: phone,
        password: password,
        fullName: fullName,
        device: device,
      );
      await TokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        identityId: response.user.identityId,
      );
      _authResponse = response;
      _currentUser = response.user; // added
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required String device,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.login(
        email: email,
        password: password,
        device: device,
      );
      await TokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        identityId: response.user.identityId,
      );
      _authResponse = response;
      _currentUser = response.user; // added
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // New method to fetch user profile
  Future<bool> fetchUserProfile() async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _repository.getCurrentUser();
      _currentUser = user;
      // Optionally update _authResponse if needed
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  Future<bool> verifyEmail(String token) async {
  _setLoading(true);
  _clearError();
  try {
    await _repository.verifyEmail(token);
    _setLoading(false);
    return true;
  } catch (e) {
    _setError(e.toString());
    _setLoading(false);
    return false;
  }
}

Future<bool> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  _setLoading(true);
  _clearError();
  try {
    await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    _setLoading(false);
    return true;
  } catch (e) {
    _setError(e.toString());
    _setLoading(false);
    return false;
  }
}

Future<bool> forgotPassword(String email) async {
  _setLoading(true);
  _clearError();
  try {
    await _repository.forgotPassword(email);
    _setLoading(false);
    return true;
  } catch (e) {
    _setError(e.toString());
    _setLoading(false);
    return false;
  }
}

Future<bool> resendVerification() async {
  _setLoading(true);
  _clearError();
  try {
    await _repository.resendVerification();
    _setLoading(false);
    return true;
  } catch (e) {
    _setError(e.toString());
    _setLoading(false);
    return false;
  }
}

  Future<bool> logoutAll() async {
  try {
    await _repository.logoutAll();
    await TokenStorage.clearTokens();
    _authResponse = null;
    _currentUser = null;
    notifyListeners();
    return true;
  } catch (e) {
    _setError(e.toString());
    return false;
  }
}
// Also make sure logoutAll is already there (it is)

 Future<bool> logout() async {
  try {
    await _repository.logout();
  } catch (e) {
    // ignore server error, still clear local
  } finally {
    await TokenStorage.clearTokens();
    _authResponse = null;
    _currentUser = null;
    notifyListeners();
  }
  return true; // always return true because we cleared local tokens
}


  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}