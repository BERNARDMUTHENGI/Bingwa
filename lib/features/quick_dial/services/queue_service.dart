import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:permission_handler/permission_handler.dart'; // added
import '../../offers/models/offer.dart';
import '../../ussd/services/ussd_service.dart';
import '../../ussd/services/ussd_parser.dart';
import '../../balance/providers/balance_provider.dart';
import '../../settings/services/settings_service.dart';
import '../../transactions/providers/transaction_provider.dart';

class QueueItem {
  final String customerPhone;
  final Offer offer;
  final int transactionId;
  final DateTime timestamp;
  final bool autoDetected;
  int retryCount;
  QueueStatus status;

  QueueItem({
    required this.customerPhone,
    required this.offer,
    required this.transactionId,
    required this.timestamp,
    this.autoDetected = false,
    this.retryCount = 0,
    this.status = QueueStatus.pending,
  });
}

enum QueueStatus { pending, processing, completed, failed }

class QueueService extends ChangeNotifier {
  final List<QueueItem> _queue = [];
  bool _isProcessing = false;
  final SettingsService _settingsService = SettingsService();
  BalanceProvider? _balanceProvider;
  TransactionProvider? _transactionProvider;

  List<QueueItem> get queue => List.unmodifiable(_queue);

  void setBalanceProvider(BalanceProvider provider) {
    debugPrint('🔁 QueueService: BalanceProvider set');
    _balanceProvider = provider;
  }

  void setTransactionProvider(TransactionProvider provider) {
    debugPrint('🔁 QueueService: TransactionProvider set');
    _transactionProvider = provider;
  }

  void addToQueue({
    required String customerPhone,
    required Offer offer,
    required int transactionId,
    bool autoDetected = false,
  }) {
    debugPrint('🔁 QueueService: Adding to queue - phone: $customerPhone, offer: ${offer.name}, txId: $transactionId');
    final item = QueueItem(
      customerPhone: customerPhone,
      offer: offer,
      transactionId: transactionId,
      timestamp: DateTime.now(),
      autoDetected: autoDetected,
    );
    _queue.add(item);
    notifyListeners();
    debugPrint('🔁 QueueService: Queue size now ${_queue.length}');
    _processQueue();
  }

  Future<String> _executeMultiStepUssd({
    required String baseCode,
    required List<String> path,
    required int subscriptionId,
    required String customerPhone,
  }) async {
    debugPrint('🔁 QueueService: Executing multi-step USSD. Base: $baseCode, path: $path');

    // Cancel any previous USSD session (if supported)
    try {
      await UssdService.cancelSession();
    } catch (e) {
      debugPrint('🔁 QueueService: Could not cancel previous session (may be fine): $e');
    }

    String? lastResponse = await UssdService.executeUssd(
      ussdCode: baseCode,
      subscriptionId: subscriptionId,
    );
    debugPrint('🔁 QueueService: Step 0 response: $lastResponse');

    for (int i = 0; i < path.length; i++) {
      await Future.delayed(const Duration(seconds: 2));

      // Replace placeholder if present
      String step = path[i];
      if (step.contains('{phone}')) {
        step = step.replaceAll('{phone}', customerPhone);
      }

      final menu = UssdParser.parseMenu(lastResponse ?? '');
      debugPrint('🔁 QueueService: Step ${i+1} menu: $menu');

      if (menu.isEmpty) {
        throw Exception('No menu options found at step ${i+1}');
      }
      if (!menu.containsKey(step)) {
        throw Exception('Option $step not available at step ${i+1}. Available: ${menu.keys.join(', ')}');
      }

      lastResponse = await UssdService.executeUssd(
        ussdCode: step,
        subscriptionId: subscriptionId,
      );
      debugPrint('🔁 QueueService: Step ${i+1} response: $lastResponse');
    }

    return lastResponse ?? '';
  }

  bool _isNetworkBlocked(String response) {
    final lower = response.toLowerCase();
    return lower.contains('max number of menu retries') ||
           lower.contains('too many attempts') ||
           lower.contains('try again later');
  }

  Future<void> _processQueue() async {
    if (_isProcessing) {
      debugPrint('🔁 QueueService: Already processing, exit');
      return;
    }
    if (_queue.isEmpty) {
      debugPrint('🔁 QueueService: Queue empty, nothing to process');
      return;
    }
    _isProcessing = true;
    debugPrint('🔁 QueueService: Starting queue processing. Total items: ${_queue.length}');

    while (_queue.isNotEmpty) {
      final item = _queue.firstWhere(
        (i) => i.status == QueueStatus.pending,
        orElse: () => QueueItem(
          customerPhone: '',
          offer: Offer(
            id: 0,
            name: '',
            type: '',
            bundleAmount: 0,
            units: '',
            price: 0,
            currency: '',
            validityDays: 0,
            ussdCodeTemplate: '',
            ussdProcessingType: '',
          ),
          transactionId: 0,
          timestamp: DateTime.now(),
        ),
      );

      if (item.customerPhone.isEmpty) {
        debugPrint('🔁 QueueService: No pending items found, breaking.');
        break;
      }

      debugPrint('🔁 QueueService: Processing item for transaction ${item.transactionId}');
      item.status = QueueStatus.processing;
      notifyListeners();

      try {
        if (_transactionProvider != null) {
          debugPrint('🔁 QueueService: Marking transaction ${item.transactionId} as processing');
          await _transactionProvider!.markAsProcessing(item.transactionId);
        }

        // --- SIM validation and permission checks ---
        // 1. Get the selected Bingwa SIM ID
        int? bingwaSimId = await _settingsService.getBingwaSimId();
        if (bingwaSimId == null) {
          throw Exception('Bingwa SIM not selected.');
        }
        debugPrint('🔁 QueueService: Stored SIM ID $bingwaSimId');

        // 2. Validate that this SIM exists on the device
        final sims = await UssdService.getSimCards();
        debugPrint('🔁 QueueService: Available SIMs: ${sims.map((s) => '${s.slotIndex}:${s.subscriptionId}').toList()}');
        bool simFound = sims.any((sim) => sim.subscriptionId == bingwaSimId);
        if (!simFound) {
          if (sims.isNotEmpty) {
            // Fallback to first available SIM
            int newSimId = sims.first.subscriptionId;
            debugPrint('🔁 QueueService: Selected SIM $bingwaSimId not found, falling back to $newSimId');
            await _settingsService.saveBingwaSimId(newSimId);
            bingwaSimId = newSimId;
          } else {
            throw Exception('No SIM cards found on device.');
          }
        }

        // 3. Request overlay permission if needed (improves USSD dialog handling)
        if (!await Permission.systemAlertWindow.isGranted) {
          debugPrint('🔁 QueueService: Requesting SYSTEM_ALERT_WINDOW permission');
          await Permission.systemAlertWindow.request();
        }

        // 4. Small delay before USSD to ensure network readiness
        await Future.delayed(const Duration(seconds: 2));
        // ---------------------------------------------

        debugPrint('🔁 QueueService: Using SIM ID $bingwaSimId after validation');

        // DEBUG: print menuPath before deciding path
        debugPrint('🔁 QueueService: Checking menuPath for offer ${item.offer.id}: ${item.offer.menuPath}');

        String baseCode = item.offer.ussdCodeTemplate;
        String formattedTemplate = baseCode.replaceAll('{phone}', item.customerPhone);

        final String finalResponse;
        if (item.offer.menuPath != null && item.offer.menuPath!.isNotEmpty) {
          debugPrint('🔁 QueueService: Multi-step USSD');
          finalResponse = await _executeMultiStepUssd(
            baseCode: baseCode,
            path: item.offer.menuPath!,
            subscriptionId: bingwaSimId,
            customerPhone: item.customerPhone,
          );
        } else {
          debugPrint('🔁 QueueService: Single-step USSD');
          finalResponse = await UssdService.executeUssd(
            ussdCode: formattedTemplate,
            subscriptionId: bingwaSimId,
          );
        }
        debugPrint('🔁 QueueService: Final USSD response: $finalResponse');

        if (_isNetworkBlocked(finalResponse)) {
          throw Exception('Network blocked USSD: $finalResponse (do not retry)');
        }

        if (item.offer.ussdExpectedResponse != null &&
            !finalResponse.contains(item.offer.ussdExpectedResponse!)) {
          throw Exception('Expected response not found: ${item.offer.ussdExpectedResponse}');
        }
        if (item.offer.ussdErrorPattern != null &&
            RegExp(item.offer.ussdErrorPattern!).hasMatch(finalResponse)) {
          throw Exception('Error pattern matched: ${item.offer.ussdErrorPattern}');
        }
        if (!UssdParser.isSuccess(finalResponse)) {
          throw Exception('USSD did not confirm success: $finalResponse');
        }
        debugPrint('🔁 QueueService: USSD successful');

        final balance = UssdParser.extractBalance(finalResponse);
        if (balance != null && _balanceProvider != null) {
          debugPrint('🔁 QueueService: Updating balance: $balance');
          await _balanceProvider!.updateBalance(balance);
          await _balanceProvider!.incrementUsedToday(item.offer.price);
        }

        if (_transactionProvider != null) {
          debugPrint('🔁 QueueService: Marking transaction ${item.transactionId} as completed');
          await _transactionProvider!.completeRequest(
            item.transactionId,
            ussdResponse: finalResponse,
            ussdSessionId: 'auto',
            ussdProcessingTime: 0,
            status: 'success',
          );
        }

        item.status = QueueStatus.completed;
        debugPrint('🔁 QueueService: Item completed successfully');
      } catch (e) {
        debugPrint('🔁 QueueService: Error processing item: $e');
        if (_transactionProvider != null) {
          await _transactionProvider!.completeRequest(
            item.transactionId,
            ussdResponse: e.toString(),
            ussdSessionId: '',
            ussdProcessingTime: 0,
            status: 'failed',
          );
        }

        final errorMsg = e.toString();
        if (errorMsg.contains('do not retry') || item.retryCount >= 3) {
          item.status = QueueStatus.failed;
          debugPrint('🔁 QueueService: Max retries reached or non‑retryable error, marked failed');
        } else {
          item.retryCount++;
          item.status = QueueStatus.pending;
          int delaySeconds = 10 * (1 << (item.retryCount - 1));
          debugPrint('🔁 QueueService: Retry #${item.retryCount} scheduled after ${delaySeconds}s');
          await Future.delayed(Duration(seconds: delaySeconds));
        }
      }
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
    }

    _isProcessing = false;
    debugPrint('🔁 QueueService: Queue processing finished');
  }
}