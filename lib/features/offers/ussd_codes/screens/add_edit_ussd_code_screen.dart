import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ussd_code_provider.dart';
import '../models/ussd_code.dart';

class AddEditUssdCodeScreen extends StatefulWidget {
  final int offerId;
  final UssdCode? ussdCode;

  const AddEditUssdCodeScreen({super.key, required this.offerId, this.ussdCode});

  @override
  State<AddEditUssdCodeScreen> createState() => _AddEditUssdCodeScreenState();
}

class _AddEditUssdCodeScreenState extends State<AddEditUssdCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ussdCodeController;
  late TextEditingController _signatureController;
  late TextEditingController _priorityController;
  late TextEditingController _expectedResponseController;
  late TextEditingController _errorPatternController;
  String _processingType = 'single';
  final List<String> _processingTypes = ['single', 'multistep', 'express'];

  @override
  void initState() {
    super.initState();
    _ussdCodeController = TextEditingController(text: widget.ussdCode?.ussdCode ?? '');
    _signatureController = TextEditingController(text: widget.ussdCode?.signaturePattern ?? '');
    _priorityController = TextEditingController(text: (widget.ussdCode?.priority ?? 1).toString());
    _expectedResponseController = TextEditingController(text: widget.ussdCode?.expectedResponse ?? '');
    _errorPatternController = TextEditingController(text: widget.ussdCode?.errorPattern ?? '');
    _processingType = widget.ussdCode?.processingType ?? 'single';
  }

  @override
  void dispose() {
    _ussdCodeController.dispose();
    _signatureController.dispose();
    _priorityController.dispose();
    _expectedResponseController.dispose();
    _errorPatternController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final priority = int.tryParse(_priorityController.text) ?? 1;
    final data = {
      'ussd_code': _ussdCodeController.text.trim(),
      if (_signatureController.text.isNotEmpty) 'signature_pattern': _signatureController.text.trim(),
      'priority': priority,
      'processing_type': _processingType,
      if (_expectedResponseController.text.isNotEmpty) 'expected_response': _expectedResponseController.text.trim(),
      if (_errorPatternController.text.isNotEmpty) 'error_pattern': _errorPatternController.text.trim(),
    };

    final provider = Provider.of<UssdCodeProvider>(context, listen: false);
    bool success;
    if (widget.ussdCode == null) {
      success = await provider.createUssdCode(widget.offerId, data);
    } else {
      success = await provider.updateUssdCode(widget.offerId, widget.ussdCode!.id, data);
    }
    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Operation failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UssdCodeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ussdCode == null ? 'Add USSD Code' : 'Edit USSD Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _ussdCodeController,
                decoration: const InputDecoration(labelText: 'USSD Code *'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _signatureController,
                decoration: const InputDecoration(labelText: 'Signature Pattern (optional)'),
              ),
              TextFormField(
                controller: _priorityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Priority *'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (int.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _processingType,
                items: _processingTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (val) => setState(() => _processingType = val!),
                decoration: const InputDecoration(labelText: 'Processing Type *'),
              ),
              TextFormField(
                controller: _expectedResponseController,
                decoration: const InputDecoration(labelText: 'Expected Response (optional)'),
              ),
              TextFormField(
                controller: _errorPatternController,
                decoration: const InputDecoration(labelText: 'Error Pattern (optional)'),
              ),
              const SizedBox(height: 20),
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.ussdCode == null ? 'Create' : 'Update'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}