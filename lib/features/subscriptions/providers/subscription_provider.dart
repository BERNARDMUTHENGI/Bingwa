import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../repositories/subscription_repository.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionRepository _repository = SubscriptionRepository();

  List<Subscription> _subscriptions = [];
  Subscription? _currentSubscription;
  Map<String, dynamic> _usage = {};
  Map<String, dynamic> _stats = {};
  bool _hasAccess = false;
  bool _isLoading = false;
  String? _error;

  List<Subscription> get subscriptions => _subscriptions;
  Subscription? get currentSubscription => _currentSubscription;
  Map<String, dynamic> get usage => _usage;
  Map<String, dynamic> get stats => _stats;
  bool get hasAccess => _hasAccess;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Create subscription
  Future<bool> createSubscription({
    required int planId,
    String? promoCode,
    required bool autoRenew,
    required double amountPaid,
    required String currency,
    required String paymentRef,
    required String paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final sub = await _repository.createSubscription(
        subscriptionPlanId: planId,
        promotionalCode: promoCode,
        autoRenew: autoRenew,
        amountPaid: amountPaid,
        currency: currency,
        paymentReference: paymentRef,
        paymentMethod: paymentMethod,
        metadata: metadata,
      );
      _subscriptions.add(sub);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Load subscriptions
  Future<void> loadSubscriptions({int page = 1, int pageSize = 20}) async {
    _setLoading(true);
    _clearError();
    try {
      _subscriptions = await _repository.getSubscriptions(page: page, pageSize: pageSize);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load active subscriptions
  Future<void> loadActiveSubscriptions() async {
    _setLoading(true);
    _clearError();
    try {
      _subscriptions = await _repository.getActiveSubscriptions();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load subscription by id
  Future<void> loadSubscriptionById(int id) async {
    _setLoading(true);
    _clearError();
    try {
      _currentSubscription = await _repository.getSubscriptionById(id);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Renew subscription
  Future<bool> renewSubscription({
    required double amountPaid,
    required String currency,
    required String paymentRef,
    required String paymentMethod,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final sub = await _repository.renewSubscription(
        amountPaid: amountPaid,
        currency: currency,
        paymentReference: paymentRef,
        paymentMethod: paymentMethod,
      );
      // Update or add to list
      final index = _subscriptions.indexWhere((s) => s.id == sub.id);
      if (index != -1) {
        _subscriptions[index] = sub;
      } else {
        _subscriptions.add(sub);
      }
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
      _subscriptions.removeWhere((s) => s.id == id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Check access
  Future<void> checkAccess() async {
    try {
      _hasAccess = await _repository.checkAccess();
      notifyListeners();
    } catch (e) {
      _hasAccess = false;
    }
  }

  // Load usage
  Future<void> loadUsage() async {
    try {
      _usage = await _repository.getCurrentUsage();
      notifyListeners();
    } catch (e) {
      // ignore
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