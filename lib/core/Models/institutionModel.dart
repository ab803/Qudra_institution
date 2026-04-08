class InstitutionModel {
  final String id;
  final DateTime createdAt;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String institutionType;
  final String location;

  const InstitutionModel({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.institutionType,
    required this.location,
  });

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      id: json['id'] as String,

      // ✅ FIX هنا
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),

      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      institutionType: json['institution_type'] as String,
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'institution_type': institutionType,
    'location': location,
  };
}