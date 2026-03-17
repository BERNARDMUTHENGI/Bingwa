class TransactionRequest {
  final int id;
  final int offerId;
  final String customerPhone;
  final String? customerName;
  final String paymentMethod;
  final double amountPaid;
  final String currency;
  final String status; // pending, processing, completed, failed
  final String? mpesaTransactionId;
  final String? mpesaReceiptNumber;
  final DateTime? mpesaTransactionDate;
  final String? mpesaPhoneNumber;
  final String? mpesaMessage;
  final Map<String, dynamic>? deviceInfo;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? ussdResponse;
  final String? ussdSessionId;
  final int? ussdProcessingTime;

  TransactionRequest({
    required this.id,
    required this.offerId,
    required this.customerPhone,
    this.customerName,
    required this.paymentMethod,
    required this.amountPaid,
    required this.currency,
    required this.status,
    this.mpesaTransactionId,
    this.mpesaReceiptNumber,
    this.mpesaTransactionDate,
    this.mpesaPhoneNumber,
    this.mpesaMessage,
    this.deviceInfo,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.ussdResponse,
    this.ussdSessionId,
    this.ussdProcessingTime,
  });

  /// Helper to extract a value from a wrapped field like {"String": "...", "Valid": true}
  static T? _extractWrapped<T>(Map<String, dynamic>? json, String key, T Function(dynamic) convert) {
    if (json == null) return null;
    final valid = json['Valid'] as bool? ?? false;
    if (!valid) return null;
    final value = json['String'] ?? json['Int64'] ?? json['Time'];
    return convert(value);
  }

  factory TransactionRequest.fromJson(Map<String, dynamic> json) {
    // If the JSON contains a nested "offer_request", use that
    final data = json['offer_request'] ?? json;

    return TransactionRequest(
      id: data['id'] as int,
      offerId: data['offer_id'] as int,
      customerPhone: data['customer_phone'] as String,
      customerName: data['customer_name'] is Map
          ? _extractWrapped<String>(data['customer_name'] as Map<String, dynamic>?, 'customer_name', (v) => v as String)
          : data['customer_name'] as String?,
      paymentMethod: data['payment_method'] as String,
      amountPaid: (data['amount_paid'] as num).toDouble(),
      currency: data['currency'] as String,
      status: data['status'] as String,
      mpesaTransactionId: data['mpesa_transaction_id'] is Map
          ? _extractWrapped<String>(data['mpesa_transaction_id'] as Map<String, dynamic>?, 'mpesa_transaction_id', (v) => v as String)
          : data['mpesa_transaction_id'] as String?,
      mpesaReceiptNumber: data['mpesa_receipt_number'] is Map
          ? _extractWrapped<String>(data['mpesa_receipt_number'] as Map<String, dynamic>?, 'mpesa_receipt_number', (v) => v as String)
          : data['mpesa_receipt_number'] as String?,
      mpesaTransactionDate: data['mpesa_transaction_date'] is Map
          ? _extractWrapped<DateTime>(data['mpesa_transaction_date'] as Map<String, dynamic>?, 'mpesa_transaction_date', (v) => DateTime.parse(v as String))
          : data['mpesa_transaction_date'] != null
              ? DateTime.parse(data['mpesa_transaction_date'])
              : null,
      mpesaPhoneNumber: data['mpesa_phone_number'] is Map
          ? _extractWrapped<String>(data['mpesa_phone_number'] as Map<String, dynamic>?, 'mpesa_phone_number', (v) => v as String)
          : data['mpesa_phone_number'] as String?,
      mpesaMessage: data['mpesa_message'] is Map
          ? _extractWrapped<String>(data['mpesa_message'] as Map<String, dynamic>?, 'mpesa_message', (v) => v as String)
          : data['mpesa_message'] as String?,
      deviceInfo: data['device_info'] as Map<String, dynamic>?,
      metadata: data['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
      ussdResponse: data['ussd_response'] as String?,
      ussdSessionId: data['ussd_session_id'] as String?,
      ussdProcessingTime: data['ussd_processing_time'] as int?,
    );
  } 

  Map<String, dynamic> toJson() {
    return {
      'offer_id': offerId,
      'customer_phone': customerPhone,
      if (customerName != null) 'customer_name': customerName,
      'payment_method': paymentMethod,
      'amount_paid': amountPaid,
      'currency': currency,
      'status': status,
      if (mpesaTransactionId != null) 'mpesa_transaction_id': mpesaTransactionId,
      if (mpesaReceiptNumber != null) 'mpesa_receipt_number': mpesaReceiptNumber,
      if (mpesaTransactionDate != null) 'mpesa_transaction_date': mpesaTransactionDate!.toIso8601String(),
      if (mpesaPhoneNumber != null) 'mpesa_phone_number': mpesaPhoneNumber,
      if (mpesaMessage != null) 'mpesa_message': mpesaMessage,
      if (deviceInfo != null) 'device_info': deviceInfo,
      if (metadata != null) 'metadata': metadata,
    };
  }
}