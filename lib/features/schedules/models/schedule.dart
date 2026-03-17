class Schedule {
  final int id;
  final int offerId;
  final String customerPhone;
  final DateTime scheduledTime;
  final bool autoRenew;
  final String? renewalPeriod;
  final int? renewalLimit;
  final DateTime? renewUntil;
  final String status; // pending, executed, cancelled, paused
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? executedAt;

  Schedule({
    required this.id,
    required this.offerId,
    required this.customerPhone,
    required this.scheduledTime,
    required this.autoRenew,
    this.renewalPeriod,
    this.renewalLimit,
    this.renewUntil,
    required this.status,
    this.metadata,
    required this.createdAt,
    this.executedAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      offerId: json['offer_id'],
      customerPhone: json['customer_phone'],
      scheduledTime: DateTime.parse(json['scheduled_time']),
      autoRenew: json['auto_renew'],
      renewalPeriod: json['renewal_period'],
      renewalLimit: json['renewal_limit'],
      renewUntil: json['renew_until'] != null ? DateTime.parse(json['renew_until']) : null,
      status: json['status'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      executedAt: json['executed_at'] != null ? DateTime.parse(json['executed_at']) : null,
    );
  }
}