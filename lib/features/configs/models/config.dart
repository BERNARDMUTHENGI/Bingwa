class Config {
  final int id;
  final String key;
  final dynamic value; // could be string, int, bool, or nested object
  final String? type; // e.g., 'business', 'display', 'security', 'ussd', 'android'
  final String? description;
  final int? deviceId; // null for global configs
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Config({
    required this.id,
    required this.key,
    required this.value,
    this.type,
    this.description,
    this.deviceId,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      id: json['id'],
      key: json['key'],
      value: json['value'],
      type: json['type'],
      description: json['description'],
      deviceId: json['device_id'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (deviceId != null) 'device_id': deviceId,
      if (metadata != null) 'metadata': metadata,
    };
  }
}