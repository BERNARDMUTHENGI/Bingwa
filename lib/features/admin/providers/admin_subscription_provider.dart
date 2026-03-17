import 'package:flutter/material.dart';
import '../../subscriptions/models/subscription.dart';
import '../repositories/admin_subscription_repository.dart';

class AdminSubscriptionProvider extends ChangeNotifier {
  final AdminSubscriptionRepository _repository = AdminSubscriptionRepository();

  List<Subscription> _subscriptions = [];
  Subscription? _selectedSubscription;
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _error;

  List<Subscription> get subscriptions => _subscriptions;
  Subscription? get selectedSubscription => _selectedSubscription;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all subscriptions
  Future<void> loadAllSubscriptions({int page = 1, int pageSize = 20}) async {
    _setLoading(true);
    _clearError();
    try {
      _subscriptions = await _repository.getAllSubscriptions(page: page, pageSize: pageSize);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load expiring subscriptions
  Future<void> loadExpiringSubscriptions({int days = 7}) async {
    _setLoading(true);
    _clearError();
    try {
      _subscriptions = await _repository.getExpiringSubscriptions(days: days);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Get subscription by id
  Future<void> loadSubscriptionById(int id) async {
    _setLoading(true);
    _clearError();
    try {
      _selectedSubscription = await _repository.getSubscriptionById(id);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Deactivate subscription
  Future<bool> deactivateSubscription(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.deactivateSubscription(id);
      // Update local list status
      final index = _subscriptions.indexWhere((s) => s.id == id);
      if (index != -1) {
        // You may want to reload or update the status locally
        // For simplicity, we'll reload the list
        await loadAllSubscriptions();
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Suspend subscription
  Future<bool> suspendSubscription(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.suspendSubscription(id);
      await loadAllSubscriptions(); // refresh
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Reactivate subscription
  Future<bool> reactivateSubscription(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.reactivateSubscription(id);
      await loadAllSubscriptions();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Cancel subscription
  Future<bool> cancelSubscription(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.cancelSubscription(id);
      await loadAllSubscriptions();
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
      _stats = await _repository.getSubscriptionStats();
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