import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/config_provider.dart';

class UssdConfigScreen extends StatefulWidget {
  const UssdConfigScreen({super.key});

  @override
  State<UssdConfigScreen> createState() => _UssdConfigScreenState();
}

class _UssdConfigScreenState extends State<UssdConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _timeoutController;
  late TextEditingController _retryController;

  @override
  void initState() {
    super.initState();
    final config = Provider.of<ConfigProvider>(context, listen: false).ussdConfig;
    _timeoutController = TextEditingController(text: (config['timeout_seconds'] ?? 30).toString());
    _retryController = TextEditingController(text: (config['retry_count'] ?? 3).toString());
  }

  @override
  void dispose() {
    _timeoutController.dispose();
    _retryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'timeout_seconds': int.tryParse(_timeoutController.text) ?? 30,
      'retry_count': int.tryParse(_retryController.text) ?? 3,
    };
    final provider = Provider.of<ConfigProvider>(context, listen: false);
    final success = await provider.updateUssdConfig(data);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('USSD settings saved')),
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
      appBar: AppBar(title: const Text('USSD Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _timeoutController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Timeout (seconds)'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _retryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Retry count'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}