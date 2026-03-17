import 'package:flutter/material.dart';
import '../models/ussd_code.dart';
import '../repositories/ussd_code_repository.dart';

class UssdCodeProvider extends ChangeNotifier {
  final UssdCodeRepository _repository = UssdCodeRepository();

  List<UssdCode> _ussdCodes = [];
  UssdCode? _primaryCode;
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _error;

  List<UssdCode> get ussdCodes => _ussdCodes;
  UssdCode? get primaryCode => _primaryCode;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all USSD codes for an offer
  Future<void> loadUssdCodes(int offerId) async {
    _setLoading(true);
    _clearError();
    try {
      _ussdCodes = await _repository.getUssdCodes(offerId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load active codes
  Future<void> loadActiveCodes(int offerId) async {
    _setLoading(true);
    _clearError();
    try {
      _ussdCodes = await _repository.getActiveUssdCodes(offerId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load primary code
  Future<void> loadPrimaryCode(int offerId) async {
    _setLoading(true);
    _clearError();
    try {
      _primaryCode = await _repository.getPrimaryUssdCode(offerId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load stats
  Future<void> loadStats(int offerId) async {
    try {
      _stats = await _repository.getUssdCodeStats(offerId);
      notifyListeners();
    } catch (e) {
      // ignore
    }
  }

  // Create USSD code
  Future<bool> createUssdCode(int offerId, Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      final newCode = await _repository.createUssdCode(offerId, data);
      _ussdCodes.add(newCode);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update USSD code
  Future<bool> updateUssdCode(int offerId, int codeId, Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      final updated = await _repository.updateUssdCode(offerId, codeId, data);
      final index = _ussdCodes.indexWhere((c) => c.id == codeId);
      if (index != -1) _ussdCodes[index] = updated;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Set as primary
  Future<bool> setPrimary(int offerId, int codeId) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.setPrimaryUssdCode(offerId, codeId);
      // Refresh primary and list
      await loadPrimaryCode(offerId);
      await loadUssdCodes(offerId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Toggle status
  Future<bool> toggleStatus(int offerId, int codeId, bool isActive) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.toggleUssdCodeStatus(offerId, codeId, isActive);
      await loadUssdCodes(offerId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Delete
  Future<bool> deleteUssdCode(int offerId, int codeId) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.deleteUssdCode(offerId, codeId);
      _ussdCodes.removeWhere((c) => c.id == codeId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Record result
  Future<bool> recordResult(int offerId, {required int ussdCodeId, required bool success, required String response}) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.recordResult(offerId, ussdCodeId: ussdCodeId, success: success, response: response);
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