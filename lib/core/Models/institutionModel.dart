class InstitutionModel {
  final String id;
  final DateTime createdAt;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String institutionType;
  final String location;
  final String status;
  final bool subscribed;

  const InstitutionModel({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.institutionType,
    required this.location,
    required this.status,
    required this.subscribed,
  });

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      id: json['id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),

      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      institutionType: json['institution_type'] as String,
      location: json['location'] as String,
      status: json['status'] as String? ?? 'pending',
      subscribed: json['subscribed'] as bool? ?? false, // ✅ default value
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
    'status': status,
    'subscribed': subscribed, // ✅ هنا
  };

  InstitutionModel copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? institutionType,
    String? location,
    String? status,
    bool? subscribed,
  }) {
    return InstitutionModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      institutionType: institutionType ?? this.institutionType,
      location: location ?? this.location,
      status: status ?? this.status,
      subscribed: subscribed ?? this.subscribed,
    );
  }
}