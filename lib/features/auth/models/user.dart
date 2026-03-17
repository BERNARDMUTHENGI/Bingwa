class User {
  final int identityId;          // API returns integer
  final String email;
  final String? phone;            // optional – not returned in login/register
  final String fullName;

  User({
    required this.identityId,
    required this.email,
    this.phone,
    required this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      identityId: json['identity_id'],  // integer
      email: json['email'],
      phone: json['phone'],              // may be absent or null
      fullName: json['full_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identity_id': identityId,
      'email': email,
      'phone': phone,
      'full_name': fullName,
    };
  }
}