import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/config_provider.dart';

class DisplayConfigScreen extends StatefulWidget {
  const DisplayConfigScreen({super.key});

  @override
  State<DisplayConfigScreen> createState() => _DisplayConfigScreenState();
}

class _DisplayConfigScreenState extends State<DisplayConfigScreen> {
  String _theme = 'light';
  String _language = 'en';
  final List<String> _themes = ['light', 'dark', 'system'];
  final List<String> _languages = ['en', 'sw', 'fr'];

  @override
  void initState() {
    super.initState();
    final config = Provider.of<ConfigProvider>(context, listen: false).displayConfig;
    _theme = config['theme'] ?? 'light';
    _language = config['language'] ?? 'en';
  }

  Future<void> _save() async {
    final data = {'theme': _theme, 'language': _language};
    final provider = Provider.of<ConfigProvider>(context, listen: false);
    final success = await provider.updateDisplayConfig(data);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display settings saved')),
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
      appBar: AppBar(title: const Text('Display Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _theme,
              items: _themes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _theme = val!),
              decoration: const InputDecoration(labelText: 'Theme'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _language,
              items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (val) => setState(() => _language = val!),
              decoration: const InputDecoration(labelText: 'Language'),
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