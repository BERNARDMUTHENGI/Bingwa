class Plan {
  final int id;
  final String planCode;
  final String name;
  final String? description;
  final double price;
  final String currency;
  final double? setupFee;
  final double billingUsage;
  final String billingCycle; // e.g., 'monthly', 'yearly', 'daily', 'weekly'
  final double? overageCharge;
  final int maxOffers;
  final int maxCustomers;
  final Map<String, dynamic>? features;
  final bool isPublic;
  final Map<String, dynamic>? metadata;
  final String status; // 'active', 'inactive'
  final DateTime createdAt;
  final DateTime updatedAt;

  Plan({
    required this.id,
    required this.planCode,
    required this.name,
    this.description,
    required this.price,
    required this.currency,
    this.setupFee,
    required this.billingUsage,
    required this.billingCycle,
    this.overageCharge,
    required this.maxOffers,
    required this.maxCustomers,
    this.features,
    required this.isPublic,
    this.metadata,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      planCode: json['plan_code'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      currency: json['currency'],
      setupFee: json['setup_fee'] != null ? (json['setup_fee'] as num).toDouble() : null,
      billingUsage: (json['billing_usage'] as num).toDouble(),
      billingCycle: json['billing_cycle'],
      overageCharge: json['overage_charge'] != null ? (json['overage_charge'] as num).toDouble() : null,
      maxOffers: json['max_offers'],
      maxCustomers: json['max_customers'],
      features: json['features'],
      isPublic: json['is_public'],
      metadata: json['metadata'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}