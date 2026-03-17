import 'package:flutter/material.dart';
import '../models/plan.dart';
import '../repositories/plan_repository.dart';

class PlanProvider extends ChangeNotifier {
  final PlanRepository _repository = PlanRepository();

  List<Plan> _publicPlans = [];
  List<Plan> _allPlans = [];
  Plan? _selectedPlan;
  bool _isLoading = false;
  String? _error;

  List<Plan> get publicPlans => _publicPlans;
  List<Plan> get allPlans => _allPlans;
  Plan? get selectedPlan => _selectedPlan;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load public plans
  Future<void> loadPublicPlans() async {
    _setLoading(true);
    _clearError();
    try {
      _publicPlans = await _repository.getPublicPlans();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load all plans (paginated)
  Future<void> loadAllPlans({int page = 1, int pageSize = 20}) async {
    _setLoading(true);
    _clearError();
    try {
      _allPlans = await _repository.getPlans(page: page, pageSize: pageSize);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Get plan by id
  Future<void> loadPlanById(int id) async {
    _setLoading(true);
    _clearError();
    try {
      _selectedPlan = await _repository.getPlanById(id);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Compare plans
  Future<Map<String, dynamic>> comparePlans(int id1, int id2) async {
    _setLoading(true);
    _clearError();
    try {
      final result = await _repository.comparePlans(id1, id2);
      _setLoading(false);
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return {};
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