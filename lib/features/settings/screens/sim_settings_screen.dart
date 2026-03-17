import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../../ussd/services/ussd_service.dart';

class SimSettingsScreen extends StatefulWidget {
  const SimSettingsScreen({super.key});

  @override
  State<SimSettingsScreen> createState() => _SimSettingsScreenState();
}

class _SimSettingsScreenState extends State<SimSettingsScreen> {
  List<SimCard> _simCards = [];
  int? _selectedBingwaSimId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSims();
  }

  Future<void> _loadSims() async {
    try {
      final sims = await UssdService.getSimCards();
      final settings = SettingsService();
      final savedId = await settings.getBingwaSimId();

      setState(() {
        _simCards = sims;
        _selectedBingwaSimId = savedId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading SIMs: $e')),
      );
    }
  }

  Future<void> _saveBingwaSim(int subscriptionId) async {
    final settings = SettingsService();
    await settings.saveBingwaSimId(subscriptionId);
    setState(() => _selectedBingwaSimId = subscriptionId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bingwa SIM saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SIM Setup')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _simCards.isEmpty
              ? const Center(child: Text('No SIM cards found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Bingwa SIM (To run USSDs)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._simCards.map((sim) => RadioListTile<int>(
                          title: Text(sim.displayName ?? 'SIM ${sim.slotIndex + 1}'),
                          subtitle: Text(sim.carrierName ?? 'Unknown carrier'),
                          value: sim.subscriptionId,
                          groupValue: _selectedBingwaSimId,
                          onChanged: (value) {
                            if (value != null) _saveBingwaSim(value);
                          },
                        )),
                    const Divider(height: 32),
                    // You can add another section for SMS SIM if needed
                  ],
                ),
    );
  }
}