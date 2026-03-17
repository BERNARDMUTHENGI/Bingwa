import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _bingwaSimIdKey = 'bingwa_sim_id';

  Future<void> saveBingwaSimId(int subscriptionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bingwaSimIdKey, subscriptionId);
  }

  Future<int?> getBingwaSimId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bingwaSimIdKey);
  }
}