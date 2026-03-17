import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/config_provider.dart';

class SecurityConfigScreen extends StatefulWidget {
  const SecurityConfigScreen({super.key});

  @override
  State<SecurityConfigScreen> createState() => _SecurityConfigScreenState();
}

class _SecurityConfigScreenState extends State<SecurityConfigScreen> {
  bool _requirePin = false;
  int _autoLockMinutes = 5;

  @override
  void initState() {
    super.initState();
    final config = Provider.of<ConfigProvider>(context, listen: false).securityConfig;
    _requirePin = config['require_pin'] ?? false;
    _autoLockMinutes = config['auto_lock_minutes'] ?? 5;
  }

  Future<void> _save() async {
    final data = {
      'require_pin': _requirePin,
      'auto_lock_minutes': _autoLockMinutes,
    };
    final provider = Provider.of<ConfigProvider>(context, listen: false);
    final success = await provider.updateSecurityConfig(data);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Security settings saved')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Save failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Require PIN'),
              value: _requirePin,
              onChanged: (val) => setState(() => _requirePin = val),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _autoLockMinutes.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Auto-lock after (minutes)'),
              onChanged: (val) => _autoLockMinutes = int.tryParse(val) ?? 5,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}