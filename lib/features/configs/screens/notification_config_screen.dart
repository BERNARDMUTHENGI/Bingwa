import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/config_provider.dart';

class NotificationConfigScreen extends StatefulWidget {
  const NotificationConfigScreen({super.key});

  @override
  State<NotificationConfigScreen> createState() => _NotificationConfigScreenState();
}

class _NotificationConfigScreenState extends State<NotificationConfigScreen> {
  bool _enabled = true;
  bool _sound = true;
  bool _vibration = false;

  @override
  void initState() {
    super.initState();
    final config = Provider.of<ConfigProvider>(context, listen: false).notificationConfig;
    _enabled = config['enabled'] ?? true;
    _sound = config['sound'] ?? true;
    _vibration = config['vibration'] ?? false;
  }

  Future<void> _save() async {
    final data = {
      'enabled': _enabled,
      'sound': _sound,
      'vibration': _vibration,
    };
    final provider = Provider.of<ConfigProvider>(context, listen: false);
    final success = await provider.updateNotificationConfig(data);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification settings saved')),
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
      appBar: AppBar(title: const Text('Notification Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _enabled,
              onChanged: (val) => setState(() => _enabled = val),
            ),
            SwitchListTile(
              title: const Text('Sound'),
              value: _sound,
              onChanged: (val) => setState(() => _sound = val),
            ),
            SwitchListTile(
              title: const Text('Vibration'),
              value: _vibration,
              onChanged: (val) => setState(() => _vibration = val),
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