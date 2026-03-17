import 'package:flutter/foundation.dart' show debugPrint;
import 'package:ussd_advanced/ussd_advanced.dart';
import 'package:sim_data/sim_data.dart';

class UssdService {
  /// Execute a USSD code on the specified SIM
  static Future<String> executeUssd({
    required String ussdCode,
    required int subscriptionId,
  }) async {
    debugPrint('📞 USSD: Sending code "$ussdCode" on SIM $subscriptionId');
    try {
      final String? response = await UssdAdvanced.sendAdvancedUssd(
        code: ussdCode,
        subscriptionId: subscriptionId,
      );
      debugPrint('📞 USSD: Response: "$response"');
      return response ?? 'No response';
    } catch (e) {
      debugPrint('📞 USSD: Execution failed: $e');
      throw Exception('USSD execution failed: $e');
    }
  }

static Future<void> cancelSession() async {
  debugPrint('📞 USSD: Session cancel not supported by plugin');
}

  /// Get available SIM cards
  static Future<List<SimCard>> getSimCards() async {
    debugPrint('📞 USSD: Fetching SIM cards...');
    try {
      final SimData simData = await SimDataPlugin.getSimData();
      debugPrint('📞 USSD: Found ${simData.cards.length} SIM(s)');
      return simData.cards.map((sim) {
        return SimCard(
          subscriptionId: sim.subscriptionId,
          displayName: sim.displayName,
          carrierName: sim.carrierName,
          slotIndex: sim.slotIndex,
        );
      }).toList();
    } catch (e) {
      debugPrint('📞 USSD: Failed to get SIM cards: $e');
      throw Exception('Failed to get SIM cards: $e');
    }
  }
}

/// App-level SIM model
class SimCard {
  final int subscriptionId;
  final String? displayName;
  final String? carrierName;
  final int slotIndex;

  SimCard({
    required this.subscriptionId,
    this.displayName,
    this.carrierName,
    required this.slotIndex,
  });
}