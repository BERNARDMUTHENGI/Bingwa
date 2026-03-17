import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/offer_provider.dart';

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bundleAmountController = TextEditingController();
  final _unitsController = TextEditingController();
  final _priceController = TextEditingController();
  final _validityDaysController = TextEditingController();
  final _ussdCodeController = TextEditingController(); // This should be the base code for multi-step
  final _ussdProcessingTypeController = TextEditingController(text: 'express');
  final _ussdExpectedResponseController = TextEditingController(text: 'CON');
  final _ussdErrorPatternController = TextEditingController(text: 'END|ERROR');
  final _menuPathController = TextEditingController(); // new field for menu path

  String _selectedType = 'data';
  final List<String> _types = ['data', 'airtime', 'sms'];
  final String _currency = 'KES';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _bundleAmountController.dispose();
    _unitsController.dispose();
    _priceController.dispose();
    _validityDaysController.dispose();
    _ussdCodeController.dispose();
    _ussdProcessingTypeController.dispose();
    _ussdExpectedResponseController.dispose();
    _ussdErrorPatternController.dispose();
    _menuPathController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final bundleAmount = double.tryParse(_bundleAmountController.text);
    if (bundleAmount == null) return;
    final price = double.tryParse(_priceController.text);
    if (price == null) return;
    final validityDays = int.tryParse(_validityDaysController.text);
    if (validityDays == null) return;

    // Parse menu path: comma-separated values, optionally with {phone}
    List<String>? menuPath;
    if (_menuPathController.text.trim().isNotEmpty) {
      menuPath = _menuPathController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final provider = Provider.of<OfferProvider>(context, listen: false);
    final success = await provider.createOffer(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      type: _selectedType,
      bundleAmount: bundleAmount,
      units: _unitsController.text.trim(),
      price: price,
      currency: _currency,
      validityDays: validityDays,
      validityLabel: '$validityDays Days',
      ussdCodeTemplate: _ussdCodeController.text.trim(), // this should be base code for multi-step
      ussdProcessingType: _ussdProcessingTypeController.text.trim(),
      ussdExpectedResponse: _ussdExpectedResponseController.text.trim(),
      ussdErrorPattern: _ussdErrorPatternController.text.trim(),
      menuPath: menuPath, // pass the list
      // optional fields with defaults
      discountPercentage: 0,
      isFeatured: false,
      isRecurring: false,
      maxPurchasesPerCustomer: 1,
      availableFrom: DateTime.now(),
      availableUntil: DateTime.now().add(const Duration(days: 365)),
      tags: [_selectedType],
      metadata: {'source': 'mobile_app'},
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer created successfully')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to create offer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OfferProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Offer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Offer Name *'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: _types.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
                decoration: const InputDecoration(labelText: 'Type *'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bundleAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Bundle Amount (e.g., 5) *'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _unitsController,
                decoration: const InputDecoration(labelText: 'Units (GB, MB, minutes) *'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (KES) *'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _validityDaysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Validity (days) *'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (int.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ussdCodeController,
                decoration: const InputDecoration(
                  labelText: 'USSD Base Code *',
                  hintText: 'e.g., *188# (for multi-step)',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _menuPathController,
                decoration: const InputDecoration(
                  labelText: 'Menu Path (optional)',
                  hintText: 'Comma-separated steps, e.g., 8,1,1,{phone},1,2',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ussdProcessingTypeController,
                decoration: const InputDecoration(labelText: 'USSD Processing Type *'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ussdExpectedResponseController,
                decoration: const InputDecoration(labelText: 'Expected Response (e.g., CON)'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ussdErrorPatternController,
                decoration: const InputDecoration(labelText: 'Error Pattern (e.g., END|ERROR)'),
              ),
              const SizedBox(height: 32),
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Create Offer'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}