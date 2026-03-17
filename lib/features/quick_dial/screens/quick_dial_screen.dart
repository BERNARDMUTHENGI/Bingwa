import 'package:bingwa_hybrid/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bingwa_hybrid/core/widgets/app_drawer.dart';
import 'package:bingwa_hybrid/features/offers/models/offer.dart';
import 'package:bingwa_hybrid/features/offers/providers/offer_provider.dart';
import 'package:bingwa_hybrid/features/quick_dial/services/queue_service.dart';
import 'package:bingwa_hybrid/features/transactions/providers/transaction_provider.dart'; // new import

class QuickDialScreen extends StatefulWidget {
  final Offer? initialOffer;
  const QuickDialScreen({super.key, this.initialOffer});

  @override
  State<QuickDialScreen> createState() => _QuickDialScreenState();
}

class _QuickDialScreenState extends State<QuickDialScreen> {
  final TextEditingController _phoneController = TextEditingController();
  Offer? _selectedOffer;

  @override
  void initState() {
    super.initState();
    _selectedOffer = widget.initialOffer;
  }

  Future<void> _creditCustomer() async {
    if (_selectedOffer == null || _phoneController.text.isEmpty) return;

    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final queueService = Provider.of<QueueService>(context, listen: false);

    // 1. Create a transaction request on the backend
    final requestData = {
      'offer_id': _selectedOffer!.id,
      'customer_phone': _phoneController.text.trim(),
      'amount_paid': _selectedOffer!.price,
      'currency': _selectedOffer!.currency,
      'payment_method': 'mpesa', // default
      'status': 'pending',
      // optional fields can be added later
    };

    final success = await transactionProvider.createRequest(requestData);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(transactionProvider.error ?? 'Failed to create request')),
      );
      return;
    }

    // 2. Get the newly created request ID (we assume it's the first in the list or we can return it)
    final newRequest = transactionProvider.requests.firstWhere(
      (req) => req.offerId == _selectedOffer!.id && req.customerPhone == _phoneController.text.trim(),
      orElse: () => throw Exception('Request not found after creation'),
    );

    // 3. Add to queue with the transaction ID
    queueService.addToQueue(
      customerPhone: _phoneController.text,
      offer: _selectedOffer!,
      transactionId: newRequest.id, // we'll add this parameter
      autoDetected: false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request added to queue for ${_selectedOffer!.name}')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final offersProvider = Provider.of<OfferProvider>(context);
    final queueService = Provider.of<QueueService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Dial'),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Customer Phone',
                hintText: 'Enter phone number',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Offer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: offersProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: offersProvider.offers.length,
                      itemBuilder: (context, index) {
                        final offer = offersProvider.offers[index];
                        final isSelected = _selectedOffer?.id == offer.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedOffer = offer;
                            });
                          },
                          child: Card(
                            color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : null,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    offer.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${offer.currency} ${offer.price.toStringAsFixed(0)}'),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedOffer == null || _phoneController.text.isEmpty
                    ? null
                    : _creditCustomer,
                child: const Text('Credit Customer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}