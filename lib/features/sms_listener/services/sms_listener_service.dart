import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:provider/provider.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart';
import '../../offers/providers/offer_provider.dart';
import '../../quick_dial/services/queue_service.dart';
import '../../transactions/providers/transaction_provider.dart';

class SmsListenerService {
  final Telephony telephony = Telephony.instance;
  final BuildContext context;
  DateTime? _lastProcessedTimestamp;
  bool _isListening = false;

  SmsListenerService(this.context);

  Future<bool> requestPermissions() async {
    debugPrint('📱 SMS Listener: Checking/Requesting permissions...');
    final smsStatus = await Permission.sms.status;
    final phoneStatus = await Permission.phone.status;

    if (smsStatus.isGranted && phoneStatus.isGranted) {
      debugPrint('📱 Permissions already granted.');
      return true;
    }

    final statuses = await [Permission.sms, Permission.phone].request();
    final smsGranted = statuses[Permission.sms] == PermissionStatus.granted;
    final phoneGranted = statuses[Permission.phone] == PermissionStatus.granted;

    debugPrint('SMS Granted: $smsGranted');
    debugPrint('PHONE Granted: $phoneGranted');

    return smsGranted && phoneGranted;
  }

  Future<void> checkMostRecentMessage() async {
    debugPrint('📱 SMS Listener: Checking for most recent message...');
    try {
      final messages = await telephony.getInboxSms(
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );
      if (messages.isEmpty) {
        debugPrint('📱 SMS Listener: No messages in inbox.');
        return;
      }
      final latest = messages.first;
      if (latest.date == null) return;
      final msgTime = DateTime.fromMillisecondsSinceEpoch(latest.date!);
      debugPrint('📱 SMS Listener: Latest message from ${latest.address} at $msgTime');
      // Only process if it's newer than last processed or no last processed
      if (_lastProcessedTimestamp == null || msgTime.isAfter(_lastProcessedTimestamp!)) {
        debugPrint('📱 SMS Listener: Newer message, attempting to process...');
        bool processed = await _processMessage(latest);
        if (processed) {
          _lastProcessedTimestamp = msgTime;
        }
      } else {
        debugPrint('📱 SMS Listener: Latest message older than last processed, ignoring.');
      }
    } catch (e) {
      debugPrint('📱 SMS Listener: Error checking inbox: $e');
    }
  }

  void startListening() async {
    if (_isListening) {
      debugPrint('📱 SMS Listener: Already listening.');
      return;
    }
    _isListening = true;

    debugPrint('📱 SMS Listener: Starting broadcast listener...');
    if (!await requestPermissions()) {
      debugPrint('📱 SMS Listener: Permissions denied, cannot listen.');
      _isListening = false;
      return;
    }

    telephony.listenIncomingSms(
      onNewMessage: _onSmsReceived,
      onBackgroundMessage: _onBackgroundMessage,
      listenInBackground: true,
    );

    debugPrint('📱 SMS Listener: Broadcast listener started, checking for missed messages...');
    checkMostRecentMessage();
  }

  void _onSmsReceived(SmsMessage message) {
    debugPrint('📱 SMS Listener: New SMS received from ${message.address}');
    debugPrint('📱 SMS Listener: Message body: ${message.body}');
    if (message.date != null) {
      final msgTime = DateTime.fromMillisecondsSinceEpoch(message.date!);
      debugPrint('📱 SMS Listener: Message time: $msgTime');
      // Only process if newer than last processed
      if (_lastProcessedTimestamp == null || msgTime.isAfter(_lastProcessedTimestamp!)) {
        debugPrint('📱 SMS Listener: Newer message, attempting to process...');
        _processMessage(message).then((processed) {
          if (processed) {
            _lastProcessedTimestamp = msgTime;
          }
        });
      } else {
        debugPrint('📱 SMS Listener: Message older than last processed, ignoring.');
      }
    }
  }

  @pragma('vm:entry-point')
  static void _onBackgroundMessage(SmsMessage message) {
    debugPrint('📱 SMS Listener (background): Received SMS');
  }

  /// Returns true if the message was successfully processed (i.e., an offer was found and request created)
  Future<bool> _processMessage(SmsMessage message) async {
    debugPrint('📱 SMS Listener: Processing message...');
    final body = message.body ?? '';
    final sender = message.address ?? '';

    if (!sender.toUpperCase().contains('MPESA') && !body.toUpperCase().contains('MPESA')) {
      debugPrint('📱 SMS Listener: Not an M-PESA message, ignoring.');
      return false;
    }
    debugPrint('📱 SMS Listener: M-PESA message confirmed.');

    // Extract amount
    final amountRegex = RegExp(r'Ksh\s*([\d,]+\.?\d*)', caseSensitive: false);
    final amountMatch = amountRegex.firstMatch(body);
    if (amountMatch == null) {
      debugPrint('📱 SMS Listener: Could not extract amount.');
      return false;
    }
    final amountStr = amountMatch.group(1)?.replaceAll(',', '') ?? '0';
    final amount = double.tryParse(amountStr);
    if (amount == null || amount == 0) {
      debugPrint('📱 SMS Listener: Invalid amount extracted: $amountStr');
      return false;
    }
    debugPrint('📱 SMS Listener: Extracted amount: $amount');

    // Extract customer phone – more robust regex
    final phoneRegex = RegExp(
      r'(?:from|to|sent to)\s*[^0-9]*?((?:\+?254|0|7)\d{8,11})',
      caseSensitive: false,
    );
    final phoneMatch = phoneRegex.firstMatch(body);
    if (phoneMatch == null) {
      debugPrint('📱 SMS Listener: Could not extract customer phone.');
      return false;
    }
    final customerPhone = phoneMatch.group(1)!;
    final formattedPhone = _formatPhone(customerPhone);
    debugPrint('📱 SMS Listener: Customer phone (raw): $customerPhone → formatted: $formattedPhone');

    // Extract receipt (optional)
    final receiptRegex = RegExp(r'([A-Z0-9]{10})', caseSensitive: false);
    final receiptMatch = receiptRegex.firstMatch(body);
    final mpesaReceipt = receiptMatch?.group(1);
    if (mpesaReceipt != null) {
      debugPrint('📱 SMS Listener: M-PESA receipt: $mpesaReceipt');
    }

    // Capture providers
    debugPrint('📱 SMS Listener: Accessing providers...');
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final queueService = Provider.of<QueueService>(context, listen: false);

    // Find matching offer
    debugPrint('📱 SMS Listener: Searching for offer with price $amount');
    final matchingOffers = offerProvider.offers.where((o) => o.price == amount).toList();
    if (matchingOffers.isEmpty) {
      debugPrint('📱 SMS Listener: No offer found for amount $amount');
      return false;
    }
    final offer = matchingOffers.first;
    debugPrint('📱 SMS Listener: Found matching offer: ${offer.name} (ID: ${offer.id})');

    // Prepare request data
    final requestData = {
      'offer_id': offer.id,
      'customer_phone': formattedPhone,
      'amount_paid': amount,
      'currency': offer.currency,
      'payment_method': 'mpesa',
      'status': 'pending',
      if (mpesaReceipt != null) 'mpesa_receipt_number': mpesaReceipt,
      'mpesa_message': body,
    };
    debugPrint('📱 SMS Listener: Creating transaction with data: $requestData');

    try {
      debugPrint('📱 SMS Listener: Calling createRequest...');
      final success = await transactionProvider.createRequest(requestData);
      if (!success) {
        debugPrint('📱 SMS Listener: createRequest returned false');
        return false;
      }
      debugPrint('📱 SMS Listener: createRequest succeeded, looking for new request...');

      final newRequest = transactionProvider.requests.firstWhereOrNull(
        (req) => req.offerId == offer.id && req.customerPhone == formattedPhone,
      );
      if (newRequest == null) {
        debugPrint('📱 SMS Listener: Request not found after creation');
        return false;
      }
      debugPrint('📱 SMS Listener: New request ID: ${newRequest.id}');

      debugPrint('📱 SMS Listener: Adding to queue...');
      queueService.addToQueue(
        customerPhone: formattedPhone,
        offer: offer,
        transactionId: newRequest.id,
        autoDetected: true,
      );
      debugPrint('📱 SMS Listener: Successfully added to queue.');
      return true;
    } catch (e) {
      debugPrint('📱 SMS Listener: Failed processing transaction: $e');
      return false;
    }
  }

  String _formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) return '254${digits.substring(1)}';
    if (digits.startsWith('7')) return '254$digits';
    if (digits.startsWith('1')) return '254$digits';
    if (digits.startsWith('254')) return digits;
    return '254$digits';
  }

  void dispose() {
    _isListening = false;
    debugPrint('📱 SMS Listener: Disposed');
  }
}