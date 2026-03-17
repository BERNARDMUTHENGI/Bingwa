import 'package:hive/hive.dart';

part 'offer.g.dart';

@HiveType(typeId: 0)
class Offer {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final double bundleAmount;

  @HiveField(5)
  final String units;

  @HiveField(6)
  final double price;

  @HiveField(7)
  final String currency;

  @HiveField(8)
  final double? discountPercentage;

  @HiveField(9)
  final int validityDays;

  @HiveField(10)
  final String? validityLabel;

  @HiveField(11)
  final String ussdCodeTemplate;

  @HiveField(12)
  final String ussdProcessingType;

  @HiveField(13)
  final String? ussdExpectedResponse;

  @HiveField(14)
  final String? ussdErrorPattern;

  @HiveField(15)
  final bool? isFeatured;

  @HiveField(16)
  final bool? isRecurring;

  @HiveField(17)
  final int? maxPurchasesPerCustomer;

  @HiveField(18)
  final DateTime? availableFrom;

  @HiveField(19)
  final DateTime? availableUntil;

  @HiveField(20)
  final List<String>? tags;

  @HiveField(21)
  final Map<String, dynamic>? metadata;

  @HiveField(22)
  final String status;

  @HiveField(23)
  final List<String>? menuPath;        // e.g., ['1', '2', '3'] for a multi‑step menu

  Offer({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.bundleAmount,
    required this.units,
    required this.price,
    required this.currency,
    this.discountPercentage,
    required this.validityDays,
    this.validityLabel,
    required this.ussdCodeTemplate,
    required this.ussdProcessingType,
    this.ussdExpectedResponse,
    this.ussdErrorPattern,
    this.isFeatured,
    this.isRecurring,
    this.maxPurchasesPerCustomer,
    this.availableFrom,
    this.availableUntil,
    this.tags,
    this.metadata,
    this.status = 'active',
    this.menuPath,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    T? extractValidField<T>(Map<String, dynamic>? map, T Function(dynamic) convert) {
      if (map == null) return null;
      final valid = map['Valid'] as bool? ?? false;
      if (!valid) return null;
      final value = map['String'] ?? map['Int32'] ?? map['Time'];
      return convert(value);
    }

    // Extract menuPath: first try top-level 'menu_path', then fallback to metadata['menu_path']
    List<String>? parsedMenuPath;
    if (json['menu_path'] != null) {
      parsedMenuPath = (json['menu_path'] as List).map((e) => e.toString()).toList();
    } else if (json['metadata'] != null) {
      final meta = json['metadata'] as Map;
      if (meta.containsKey('menu_path')) {
        parsedMenuPath = (meta['menu_path'] as List).map((e) => e.toString()).toList();
      }
    }

    return Offer(
      id: json['id'] as int,
      name: json['name'] as String,
      description: extractValidField<String>(
          json['description'] as Map<String, dynamic>?, (v) => v as String),
      type: json['type'] as String,
      bundleAmount: (json['amount'] as num).toDouble(),
      units: json['units'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble(),
      validityDays: json['validity_days'] as int,
      validityLabel: extractValidField<String>(
          json['validity_label'] as Map<String, dynamic>?, (v) => v as String),
      ussdCodeTemplate: json['ussd_code_template'] as String,
      ussdProcessingType: json['ussd_processing_type'] as String,
      ussdExpectedResponse: extractValidField<String>(
          json['ussd_expected_response'] as Map<String, dynamic>?, (v) => v as String),
      ussdErrorPattern: extractValidField<String>(
          json['ussd_error_pattern'] as Map<String, dynamic>?, (v) => v as String),
      isFeatured: json['is_featured'] as bool?,
      isRecurring: json['is_recurring'] as bool?,
      maxPurchasesPerCustomer: extractValidField<int>(
          json['max_purchases_per_customer'] as Map<String, dynamic>?, (v) => v as int),
      availableFrom: extractValidField<DateTime>(
          json['available_from'] as Map<String, dynamic>?, (v) => DateTime.parse(v as String)),
      availableUntil: extractValidField<DateTime>(
          json['available_until'] as Map<String, dynamic>?, (v) => DateTime.parse(v as String)),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      status: json['status'] as String? ?? 'active',
      menuPath: parsedMenuPath,
    );
  }

  Map<String, dynamic> toJson() {
    // Build metadata including menuPath if present
    Map<String, dynamic>? finalMetadata;
    if (metadata != null || menuPath != null) {
      finalMetadata = Map<String, dynamic>.from(metadata ?? {});
      if (menuPath != null) {
        finalMetadata['menu_path'] = menuPath;
      }
    }

    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'amount': bundleAmount,
      'units': units,
      'price': price,
      'currency': currency,
      'discount_percentage': discountPercentage,
      'validity_days': validityDays,
      'validity_label': validityLabel,
      'ussd_code_template': ussdCodeTemplate,
      'ussd_processing_type': ussdProcessingType,
      'ussd_expected_response': ussdExpectedResponse,
      'ussd_error_pattern': ussdErrorPattern,
      'is_featured': isFeatured,
      'is_recurring': isRecurring,
      'max_purchases_per_customer': maxPurchasesPerCustomer,
      'available_from': availableFrom?.toIso8601String(),
      'available_until': availableUntil?.toIso8601String(),
      'tags': tags,
      'metadata': finalMetadata,
      'status': status,
    };
  }
}