import 'package:flutter/material.dart';
import '../repositories/admin_auth_repository.dart';
import '../models/auth_response.dart';
import '../../../core/utils/admin_token_storage.dart';

class AdminAuthProvider extends ChangeNotifier {
  final AdminAuthRepository _repository = AdminAuthRepository();

  bool _isLoading = false;
  String? _error;
  AuthResponse? _authResponse;

  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthResponse? get authResponse => _authResponse;

  Future<bool> adminLogin({
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
      await AdminTokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        identityId: response.user.identityId,
      );
      _authResponse = response;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
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