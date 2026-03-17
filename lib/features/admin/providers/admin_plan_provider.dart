import 'package:flutter/material.dart';
import '../repositories/admin_plan_repository.dart';

class AdminPlanProvider extends ChangeNotifier {
  final AdminPlanRepository _repository = AdminPlanRepository();

  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Create plan
  Future<bool> createPlan(Map<String, dynamic> planData) async {
    _setLoading(true);
    _clearError();
    try {
      final newPlan = await _repository.createPlan(planData);
      // Optionally emit event or refresh list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update plan
  Future<bool> updatePlan(int id, Map<String, dynamic> updateData) async {
    _setLoading(true);
    _clearError();
    try {
      final updated = await _repository.updatePlan(id, updateData);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Activate plan
  Future<bool> activatePlan(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.activatePlan(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Deactivate plan
  Future<bool> deactivatePlan(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.deactivatePlan(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Delete plan
  Future<bool> deletePlan(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.deletePlan(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Load stats
  Future<void> loadStats() async {
    try {
      _stats = await _repository.getPlanStats();
      notifyListeners();
    } catch (e) {
      // ignore
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