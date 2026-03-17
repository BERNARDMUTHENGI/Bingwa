class Subscription {
  final int id;
  final int planId;
  final String planName;
  final String status; // active, expired, cancelled, suspended
  final DateTime startDate;
  final DateTime? endDate;
  final bool autoRenew;
  final double amountPaid;
  final String currency;
  final String paymentReference;
  final String paymentMethod;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  Subscription({
    required this.id,
    required this.planId,
    required this.planName,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.autoRenew,
    required this.amountPaid,
    required this.currency,
    required this.paymentReference,
    required this.paymentMethod,
    this.metadata,
    required this.createdAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      planId: json['plan_id'],
      planName: json['plan_name'],
      status: json['status'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      autoRenew: json['auto_renew'],
      amountPaid: (json['amount_paid'] as num).toDouble(),
      currency: json['currency'],
      paymentReference: json['payment_reference'],
      paymentMethod: json['payment_method'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}