import 'package:flutter/material.dart';
import '../models/config.dart';
import '../repositories/config_repository.dart';

class ConfigProvider extends ChangeNotifier {
  final ConfigRepository _repository = ConfigRepository();

  List<Config> _configs = [];
  Config? _selectedConfig;
  Map<String, dynamic> _businessConfig = {};
  Map<String, dynamic> _displayConfig = {};
  Map<String, dynamic> _securityConfig = {};
  Map<String, dynamic> _ussdConfig = {};
  Map<String, dynamic> _notificationConfig = {};
  Map<String, dynamic> _androidConfig = {};
  bool _isLoading = false;
  String? _error;

  List<Config> get configs => _configs;
  Config? get selectedConfig => _selectedConfig;
  Map<String, dynamic> get businessConfig => _businessConfig;
  Map<String, dynamic> get displayConfig => _displayConfig;
  Map<String, dynamic> get securityConfig => _securityConfig;
  Map<String, dynamic> get ussdConfig => _ussdConfig;
  Map<String, dynamic> get notificationConfig => _notificationConfig;
  Map<String, dynamic> get androidConfig => _androidConfig;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllConfigs() async {
    _setLoading(true);
    _clearError();
    try {
      _configs = await _repository.getAllConfigs();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadConfigByKey(String key, {String? deviceId}) async {
    _setLoading(true);
    _clearError();
    try {
      _selectedConfig = await _repository.getConfigByKey(key, deviceId: deviceId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadBusinessConfig() async {
    try {
      _businessConfig = await _repository.getBusinessConfig();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadDisplayConfig() async {
    try {
      _displayConfig = await _repository.getDisplayConfig();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadSecurityConfig() async {
    try {
      _securityConfig = await _repository.getSecurityConfig();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadUssdConfig() async {
    try {
      _ussdConfig = await _repository.getUssdConfig();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadNotificationConfig() async {
    try {
      _notificationConfig = await _repository.getNotificationConfig();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadAndroidDeviceConfig(String deviceId) async {
    try {
      _androidConfig = await _repository.getAndroidDeviceConfig(deviceId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> updateBusinessConfig(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      _businessConfig = await _repository.setBusinessConfig(data);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateDisplayConfig(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      _displayConfig = await _repository.setDisplayConfig(data);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateSecurityConfig(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      _securityConfig = await _repository.setSecurityConfig(data);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateUssdConfig(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      _ussdConfig = await _repository.setUssdConfig(data);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateNotificationConfig(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      _notificationConfig = await _repository.setNotificationConfig(data);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateAndroidDeviceConfig(String deviceId, Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      _androidConfig = await _repository.setAndroidDeviceConfig(deviceId, data);
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