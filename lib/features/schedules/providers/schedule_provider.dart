import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../repositories/schedule_repository.dart';

class ScheduleProvider extends ChangeNotifier {
  final ScheduleRepository _repository = ScheduleRepository();

  List<Schedule> _schedules = [];
  Schedule? _selectedSchedule;
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _error;

  List<Schedule> get schedules => _schedules;
  Schedule? get selectedSchedule => _selectedSchedule;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all schedules
  Future<void> loadSchedules({int page = 1, int pageSize = 20}) async {
    _setLoading(true);
    _clearError();
    try {
      _schedules = await _repository.getSchedules(page: page, pageSize: pageSize);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load due schedules
  Future<void> loadDueSchedules() async {
    _setLoading(true);
    _clearError();
    try {
      _schedules = await _repository.getDueSchedules();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load schedule by id
  Future<void> loadScheduleById(int id) async {
    _setLoading(true);
    _clearError();
    try {
      _selectedSchedule = await _repository.getScheduleById(id);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Create schedule
  Future<bool> createSchedule({
    required int offerId,
    required String customerPhone,
    required DateTime scheduledTime,
    required bool autoRenew,
    String? renewalPeriod,
    int? renewalLimit,
    DateTime? renewUntil,
    Map<String, dynamic>? metadata,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final newSchedule = await _repository.createSchedule(
        offerId: offerId,
        customerPhone: customerPhone,
        scheduledTime: scheduledTime,
        autoRenew: autoRenew,
        renewalPeriod: renewalPeriod,
        renewalLimit: renewalLimit,
        renewUntil: renewUntil,
        metadata: metadata,
      );
      _schedules.add(newSchedule);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update schedule
  Future<bool> updateSchedule(int id, Map<String, dynamic> updateData) async {
    _setLoading(true);
    _clearError();
    try {
      final updated = await _repository.updateSchedule(id, updateData);
      final index = _schedules.indexWhere((s) => s.id == id);
      if (index != -1) _schedules[index] = updated;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Pause schedule
  Future<bool> pauseSchedule(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.pauseSchedule(id);
      // Optionally update status locally
      final index = _schedules.indexWhere((s) => s.id == id);
      if (index != -1) {
        // We could update status manually, but for simplicity reload
        await loadSchedules();
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Resume schedule
  Future<bool> resumeSchedule(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.resumeSchedule(id);
      await loadSchedules();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Cancel schedule
  Future<bool> cancelSchedule(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.cancelSchedule(id);
      await loadSchedules();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Execute schedule
  Future<bool> executeSchedule(int id, {
    required String ussdResponse,
    required String ussdSessionId,
    required int ussdProcessingTime,
    required String status,
    String? failureReason,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.executeSchedule(
        id,
        ussdResponse: ussdResponse,
        ussdSessionId: ussdSessionId,
        ussdProcessingTime: ussdProcessingTime,
        status: status,
        failureReason: failureReason,
      );
      await loadSchedules();
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
      _stats = await _repository.getScheduleStats();
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