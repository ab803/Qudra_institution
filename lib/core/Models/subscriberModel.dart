class SubscriberModel {
  final String id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? disabilityType;
  final String? gender;
  final int? age;
  final DateTime? subscribedAt;

  const SubscriberModel({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    this.disabilityType,
    this.gender,
    this.age,
    this.subscribedAt,
  });

  factory SubscriberModel.fromMap(Map<String, dynamic> map) {
    final person = map['people_with_disability'] as Map<String, dynamic>? ?? map;
    return SubscriberModel(
      id: person['id'] as String,
      fullName: person['full_name'] as String?,
      email: person['email'] as String?,
      phone: person['phone'] as String?,
      disabilityType: person['disability_type'] as String?,
      gender: person['gender'] as String?,
      age: person['age'] as int?,
      subscribedAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  String get displayName => fullName?.isNotEmpty == true ? fullName! : 'Unknown';
  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }
}