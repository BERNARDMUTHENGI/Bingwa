import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/config_provider.dart';

class BusinessConfigScreen extends StatefulWidget {
  const BusinessConfigScreen({super.key});

  @override
  State<BusinessConfigScreen> createState() => _BusinessConfigScreenState();
}

class _BusinessConfigScreenState extends State<BusinessConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _businessPhoneController;

  @override
  void initState() {
    super.initState();
    final config = Provider.of<ConfigProvider>(context, listen: false).businessConfig;
    _businessNameController = TextEditingController(text: config['business_name'] ?? '');
    _businessPhoneController = TextEditingController(text: config['business_phone'] ?? '');
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessPhoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'business_name': _businessNameController.text.trim(),
      'business_phone': _businessPhoneController.text.trim(),
    };
    final provider = Provider.of<ConfigProvider>(context, listen: false);
    final success = await provider.updateBusinessConfig(data);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business settings saved')),
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
    final provider = Provider.of<ConfigProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Business Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(labelText: 'Business Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _businessPhoneController,
                decoration: const InputDecoration(labelText: 'Business Phone'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              if (provider.isLoading)
                const CircularProgressIndicator()
              else
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