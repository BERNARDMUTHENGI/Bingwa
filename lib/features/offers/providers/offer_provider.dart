import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/offer.dart';
import '../repositories/offer_repository.dart';

class OfferProvider extends ChangeNotifier {
  final OfferRepository _repository = OfferRepository();

  List<Offer> _offers = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _stats;

  List<Offer> get offers => _offers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get stats => _stats;

  OfferProvider() {
    _loadLocalOffers();
  }

  void _loadLocalOffers() {
    _offers = _repository.getLocalOffers();
    // Debug: print menuPath for each offer
    for (var offer in _offers) {
      debugPrint('📦 Offer ${offer.id} (${offer.name}): menuPath = ${offer.menuPath}');
    }
    notifyListeners();
  }

  // ==================== Basic CRUD ====================
  Future<void> syncOffers() async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.syncOffers();
      _loadLocalOffers();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createOffer({
    required String name,
    String? description,
    required String type,
    required double bundleAmount,
    required String units,
    required double price,
    required String currency,
    double? discountPercentage,
    required int validityDays,
    String? validityLabel,
    required String ussdCodeTemplate,
    required String ussdProcessingType,
    String? ussdExpectedResponse,
    String? ussdErrorPattern,
    bool? isFeatured,
    bool? isRecurring,
    int? maxPurchasesPerCustomer,
    DateTime? availableFrom,
    DateTime? availableUntil,
    List<String>? tags,
    List<String>? menuPath,
    Map<String, dynamic>? metadata,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final newOffer = await _repository.createOffer(
        name: name,
        description: description,
        type: type,
        bundleAmount: bundleAmount,
        units: units,
        price: price,
        currency: currency,
        discountPercentage: discountPercentage,
        validityDays: validityDays,
        validityLabel: validityLabel,
        ussdCodeTemplate: ussdCodeTemplate,
        ussdProcessingType: ussdProcessingType,
        ussdExpectedResponse: ussdExpectedResponse,
        ussdErrorPattern: ussdErrorPattern,
        isFeatured: isFeatured,
        isRecurring: isRecurring,
        maxPurchasesPerCustomer: maxPurchasesPerCustomer,
        availableFrom: availableFrom,
        availableUntil: availableUntil,
        tags: tags,
        menuPath: menuPath,
        metadata: metadata,
      );
      _offers.add(newOffer);
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateOffer(int id, Map<String, dynamic> updateData) async {
    _setLoading(true);
    _clearError();
    try {
      final updated = await _repository.updateOffer(id, updateData);
      final index = _offers.indexWhere((o) => o.id == id);
      if (index != -1) {
        _offers[index] = updated;
      } else {
        _offers.add(updated);
      }
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteOffer(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.deleteOffer(id);
      _offers.removeWhere((o) => o.id == id);
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ==================== Status Changes ====================
  Future<bool> activateOffer(int id) async {
    try {
      await _repository.activateOffer(id);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deactivateOffer(int id) async {
    try {
      await _repository.deactivateOffer(id);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> pauseOffer(int id) async {
    try {
      await _repository.pauseOffer(id);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<Offer?> cloneOffer(int id, String newName) async {
    _setLoading(true);
    _clearError();
    try {
      final cloned = await _repository.cloneOffer(id, newName);
      _offers.add(cloned);
      notifyListeners();
      _setLoading(false);
      return cloned;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  // ==================== Getters ====================
  Future<void> loadOffers({int page = 1, int pageSize = 20}) async {
    _setLoading(true);
    _clearError();
    try {
      _offers = await _repository.getOffers(page: page, pageSize: pageSize);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<Offer?> getOfferById(int id) async {
    _setLoading(true);
    _clearError();
    try {
      final offer = await _repository.getOfferById(id);
      _setLoading(false);
      return offer;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  Future<List<Offer>> searchOffers(String query, {String? type}) async {
    _setLoading(true);
    _clearError();
    try {
      final results = await _repository.searchOffers(query, type: type);
      _setLoading(false);
      return results;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }

  Future<void> loadStats() async {
    _setLoading(true);
    _clearError();
    try {
      _stats = await _repository.getOfferStats();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<List<Offer>> getOffersByAmount(double amount) async {
    _setLoading(true);
    _clearError();
    try {
      final results = await _repository.getOffersByAmount(amount);
      _setLoading(false);
      return results;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }

  Future<List<Offer>> getOffersByAmountRange(double min, double max) async {
    _setLoading(true);
    _clearError();
    try {
      final results = await _repository.getOffersByAmountRange(min, max);
      _setLoading(false);
      return results;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }

  Future<List<Offer>> getOffersByPrice(double price) async {
    _setLoading(true);
    _clearError();
    try {
      final results = await _repository.getOffersByPrice(price);
      _setLoading(false);
      return results;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }

  Future<List<Offer>> getOffersByTypeAndAmount(String type, double amount) async {
    _setLoading(true);
    _clearError();
    try {
      final results = await _repository.getOffersByTypeAndAmount(type, amount);
      _setLoading(false);
      return results;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }

  Future<Map<String, dynamic>> calculateOfferPrice(int id) async {
    _setLoading(true);
    _clearError();
    try {
      final result = await _repository.calculateOfferPrice(id);
      _setLoading(false);
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return {};
    }
  }

  Future<String> generateUssdCode(int id, String phone) async {
    try {
      return await _repository.generateUssdCode(id, phone);
    } catch (e) {
      _setError(e.toString());
      return '';
    }
  }

  Future<String> getUssdCodeForExecution(int id, String phone) async {
    try {
      return await _repository.getUssdCodeForExecution(id, phone);
    } catch (e) {
      _setError(e.toString());
      return '';
    }
  }

  // ==================== Category filter ====================
  List<Offer> getOffersByCategory(String category) {
    if (category == 'All') return _offers;
    return _offers.where((o) => o.type.toLowerCase() == category.toLowerCase()).toList();
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