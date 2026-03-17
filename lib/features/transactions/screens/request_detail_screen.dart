import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class RequestDetailScreen extends StatefulWidget {
  final int requestId;
  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .loadRequestById(widget.requestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final req = provider.selectedRequest;

    return Scaffold(
      appBar: AppBar(
        title: Text('Request #${widget.requestId}'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : req == null
              ? const Center(child: Text('Request not found'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      _buildInfoRow('Offer ID', req.offerId.toString()),
                      _buildInfoRow('Customer', req.customerName ?? req.customerPhone),
                      _buildInfoRow('Amount', '${req.currency} ${req.amountPaid}'),
                      _buildInfoRow('Payment Method', req.paymentMethod),
                      _buildInfoRow('Status', req.status),
                      if (req.mpesaReceiptNumber != null)
                        _buildInfoRow('M-PESA Receipt', req.mpesaReceiptNumber!),
                      if (req.ussdResponse != null)
                        _buildInfoRow('USSD Response', req.ussdResponse!),
                      if (req.ussdSessionId != null)
                        _buildInfoRow('USSD Session', req.ussdSessionId!),
                      const SizedBox(height: 20),
                      if (req.status == 'pending')
                        ElevatedButton(
                          onPressed: () async {
                            final success = await provider.markAsProcessing(req.id);
                            if (success && mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Mark as Processing'),
                        ),
                      if (req.status == 'processing')
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Simulate success completion
                                provider.completeRequest(
                                  req.id,
                                  ussdResponse: 'Test success',
                                  ussdSessionId: 'SESSION123',
                                  ussdProcessingTime: 1500,
                                  status: 'success',
                                ).then((_) => Navigator.pop(context));
                              },
                              child: const Text('Mark as Completed (Success)'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                provider.completeRequest(
                                  req.id,
                                  ussdResponse: 'Test failure',
                                  ussdSessionId: 'SESSION123',
                                  ussdProcessingTime: 1500,
                                  status: 'failed',
                                ).then((_) => Navigator.pop(context));
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Mark as Failed'),
                            ),
                          ],
                        ),
                      if (req.status == 'failed')
                        ElevatedButton(
                          onPressed: () async {
                            await provider.retryRequest(req.id);
                            Navigator.pop(context);
                          },
                          child: const Text('Retry'),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}