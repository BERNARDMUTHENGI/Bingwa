class UssdCode {
  final int id;
  final int offerId;
  final String ussdCode;
  final String? signaturePattern;
  final int priority;
  final bool isActive;
  final String processingType; // e.g., 'single', 'multistep', 'express'
  final String? expectedResponse;
  final String? errorPattern;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  UssdCode({
    required this.id,
    required this.offerId,
    required this.ussdCode,
    this.signaturePattern,
    required this.priority,
    required this.isActive,
    required this.processingType,
    this.expectedResponse,
    this.errorPattern,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UssdCode.fromJson(Map<String, dynamic> json) {
    return UssdCode(
      id: json['id'],
      offerId: json['offer_id'],
      ussdCode: json['ussd_code'],
      signaturePattern: json['signature_pattern'],
      priority: json['priority'],
      isActive: json['is_active'],
      processingType: json['processing_type'],
      expectedResponse: json['expected_response'],
      errorPattern: json['error_pattern'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ussd_code': ussdCode,
      'signature_pattern': signaturePattern,
      'priority': priority,
      'processing_type': processingType,
      'expected_response': expectedResponse,
      'error_pattern': errorPattern,
      'metadata': metadata,
    };
  }
}