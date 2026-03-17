import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/transaction_request.dart';
import '../repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();

  List<TransactionRequest> _requests = [];
  TransactionRequest? _selectedRequest;
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _error;

  List<TransactionRequest> get requests => _requests;
  TransactionRequest? get selectedRequest => _selectedRequest;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRequests({int page = 1, int pageSize = 20}) async {
    debugPrint('📊 TransactionProvider: Loading requests page $page');
    _setLoading(true);
    _clearError();
    try {
      _requests = await _repository.getRequests(page: page, pageSize: pageSize);
      debugPrint('📊 TransactionProvider: Loaded ${_requests.length} requests');
      _setLoading(false);
    } catch (e) {
      debugPrint('📊 TransactionProvider: Error loading requests: $e');
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadPendingRequests({int? limit}) async {
    debugPrint('📊 TransactionProvider: Loading pending requests (limit: $limit)');
    _setLoading(true);
    _clearError();
    try {
      _requests = await _repository.getPendingRequests(limit: limit);
      debugPrint('📊 TransactionProvider: Loaded ${_requests.length} pending requests');
      _setLoading(false);
    } catch (e) {
      debugPrint('📊 TransactionProvider: Error loading pending: $e');
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadFailedRequests() async {
    debugPrint('📊 TransactionProvider: Loading failed requests');
    _setLoading(true);
    _clearError();
    try {
      _requests = await _repository.getFailedRequests();
      debugPrint('📊 TransactionProvider: Loaded ${_requests.length} failed requests');
      _setLoading(false);
    } catch (e) {
      debugPrint('📊 TransactionProvider: Error loading failed: $e');
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadProcessingRequests() async {
    debugPrint('📊 TransactionProvider: Loading processing requests');
    _setLoading(true);
    _clearError();
    try {
      _requests = await _repository.getProcessingRequests();
      debugPrint('📊 TransactionProvider: Loaded ${_requests.length} processing requests');
      _setLoading(false);
    } catch (e) {
      debugPrint('📊 TransactionProvider: Error loading processing: $e');
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadRequestsByStatus(String status) async {
    debugPrint('📊 TransactionProvider: Loading requests with status $status');
    _setLoading(true);
    _clearError();
    try {
      _requests = await _repository.getRequestsByStatus(status);
      debugPrint('📊 TransactionProvider: Loaded ${_requests.length} requests');
      _setLoading(false);
    } catch (e) {
      debugPrint('📊 TransactionProvider: Error loading by status: $e');
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadRequestById(int id) async {
    debugPrint('📊 TransactionProvider: Loading request $id');
    _setLoading(true);
    _clearError();
    try {
      _selectedRequest = await _repository.getRequestById(id);
      debugPrint('📊 TransactionProvider: Loaded request $id');
      _setLoading(false);
    } catch (e) {
      debugPrint('📊 TransactionProvider: Error loading request $id: $e');
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<bool> createRequest(Map<String, dynamic> data) async {
    debugPrint('📊 TransactionProvider: Creating request with data: $data');
    _setLoading(true);
    _clearError();
    try {
      final newRequest = await _repository.createRequest(data);
      _requests.insert(0, newRequest);
      debugPrint('📊 TransactionProvider: Created request ID ${newRequest.id}');
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('📊 TransactionProvider: Failed to create request: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateRequestStatus(int id, String status) async {
    debugPrint('📊 TransactionProvider: Updating request $id to status $status');
    _setLoading(true);
    _clearError();
    try {
      await _repository.updateRequestStatus(id, status);
      final index = _requests.indexWhere((r) => r.id == id);
      if (index != -1) {
        // Create updated copy (simplified – in practice you'd reload or patch)
        _requests[index] = TransactionRequest(
          id: _requests[index].id,
          offerId: _requests[index].offerId,
          customerPhone: _requests[index].customerPhone,
          customerName: _requests[index].customerName,
          paymentMethod: _requests[index].paymentMethod,
          amountPaid: _requests[index].amountPaid,
          currency: _requests[index].currency,
          status: status,
          mpesaTransactionId: _requests[index].mpesaTransactionId,
          mpesaReceiptNumber: _requests[index].mpesaReceiptNumber,
          mpesaTransactionDate: _requests[index].mpesaTransactionDate,
          mpesaPhoneNumber: _requests[index].mpesaPhoneNumber,
          mpesaMessage: _requests[index].mpesaMessage,
          deviceInfo: _requests[index].deviceInfo,
          metadata: _requests[index].metadata,
          createdAt: _requests[index].createdAt,
          updatedAt: DateTime.now(),
          ussdResponse: _requests[index].ussdResponse,
          ussdSessionId: _requests[index].ussdSessionId,
          ussdProcessingTime: _requests[index].ussdProcessingTime,
        );
      }
      debugPrint('📊 TransactionProvider: Updated request $id to status $status');
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('📊 TransactionProvider: Failed to update request $id: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> completeRequest(int id, {
    required String ussdResponse,
    required String ussdSessionId,
    required int ussdProcessingTime,
    required String status,
  }) async {
    debugPrint('📊 TransactionProvider: Completing request $id with status $status');
    _setLoading(true);
    _clearError();
    try {
      await _repository.completeRequest(
        id,
        ussdResponse: ussdResponse,
        ussdSessionId: ussdSessionId,
        ussdProcessingTime: ussdProcessingTime,
        status: status,
      );
      final index = _requests.indexWhere((r) => r.id == id);
      if (index != -1) {
        _requests[index] = TransactionRequest(
          id: _requests[index].id,
          offerId: _requests[index].offerId,
          customerPhone: _requests[index].customerPhone,
          customerName: _requests[index].customerName,
          paymentMethod: _requests[index].paymentMethod,
          amountPaid: _requests[index].amountPaid,
          currency: _requests[index].currency,
          status: status == 'success' ? 'completed' : 'failed',
          mpesaTransactionId: _requests[index].mpesaTransactionId,
          mpesaReceiptNumber: _requests[index].mpesaReceiptNumber,
          mpesaTransactionDate: _requests[index].mpesaTransactionDate,
          mpesaPhoneNumber: _requests[index].mpesaPhoneNumber,
          mpesaMessage: _requests[index].mpesaMessage,
          deviceInfo: _requests[index].deviceInfo,
          metadata: _requests[index].metadata,
          createdAt: _requests[index].createdAt,
          updatedAt: DateTime.now(),
          ussdResponse: ussdResponse,
          ussdSessionId: ussdSessionId,
          ussdProcessingTime: ussdProcessingTime,
        );
      }
      debugPrint('📊 TransactionProvider: Completed request $id');
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('📊 TransactionProvider: Failed to complete request $id: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> markAsProcessing(int id) async {
    debugPrint('📊 TransactionProvider: Marking request $id as processing');
    _setLoading(true);
    _clearError();
    try {
      await _repository.markAsProcessing(id);
      final result = await updateRequestStatus(id, 'processing');
      _setLoading(false);
      return result;
    } catch (e) {
      debugPrint('📊 TransactionProvider: Failed to mark $id as processing: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> retryRequest(int id) async {
    debugPrint('📊 TransactionProvider: Retrying request $id');
    _setLoading(true);
    _clearError();
    try {
      await _repository.retryRequest(id);
      await loadRequestById(id);
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('📊 TransactionProvider: Failed to retry $id: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> loadStats() async {
    debugPrint('📊 TransactionProvider: Loading stats');
    try {
      _stats = await _repository.getTransactionStats();
      debugPrint('📊 TransactionProvider: Stats loaded: $_stats');
      notifyListeners();
    } catch (e) {
      debugPrint('📊 TransactionProvider: Error loading stats: $e');
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