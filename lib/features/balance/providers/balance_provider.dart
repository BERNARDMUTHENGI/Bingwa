import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalanceProvider extends ChangeNotifier {
  double _airtimeBalance = 0.0;
  double _airtimeUsedToday = 0.0;

  double get airtimeBalance => _airtimeBalance;
  double get airtimeUsedToday => _airtimeUsedToday;

  BalanceProvider() {
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    _airtimeBalance = prefs.getDouble('airtime_balance') ?? 0.0;
    _airtimeUsedToday = prefs.getDouble('airtime_used_today') ?? 0.0;
    notifyListeners();
  }

  Future<void> updateBalance(double newBalance) async {
    _airtimeBalance = newBalance;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('airtime_balance', newBalance);
    notifyListeners();
  }

  Future<void> incrementUsedToday(double amount) async {
    _airtimeUsedToday += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('airtime_used_today', _airtimeUsedToday);
    notifyListeners();
  }

  // Call this at the start of each day
  Future<void> resetUsedToday() async {
    _airtimeUsedToday = 0.0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('airtime_used_today', 0.0);
    notifyListeners();
  }
}