class ServiceModel {
  final String? id;
  final String institutionId;
  final String name;
  final String category;
  final String? description;
  final List<String> supportedDisabilities;
  final double price;
  final bool isFree;
  final int durationMinutes;
  final String locationMode; // on_site / home_visit / online
  final String bookingType; // request
  final String? availabilityNotes;
  final bool isActive;
  final DateTime? createdAt;

  ServiceModel({
    this.id,
    required this.institutionId,
    required this.name,
    required this.category,
    this.description,
    required this.supportedDisabilities,
    required this.price,
    required this.isFree,
    required this.durationMinutes,
    required this.locationMode,
    required this.bookingType,
    this.availabilityNotes,
    required this.isActive,
    this.createdAt,
  });

  // Create model from Supabase JSON
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String?,
      institutionId: json['institution_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      supportedDisabilities:
      (json['supported_disabilities'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      price: (json['price'] as num).toDouble(),
      isFree: (json['is_free'] as bool?) ?? false,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 30,
      locationMode: (json['location_mode'] as String?) ?? 'on_site',
      bookingType: (json['booking_type'] as String?) ?? 'request',
      availabilityNotes: json['availability_notes'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // JSON used when creating a new service
  // We do NOT send id because Supabase generates it automatically
  Map<String, dynamic> toInsertJson() => {
    'institution_id': institutionId,
    'name': name,
    'category': category,
    'description': description,
    'supported_disabilities': supportedDisabilities,
    'price': price,
    'is_free': isFree,
    'duration_minutes': durationMinutes,
    'location_mode': locationMode,
    'booking_type': bookingType,
    'availability_notes': availabilityNotes,
    'is_active': isActive,
  };

  // JSON used when updating an existing service
  // id is not included because we update by WHERE id = ...
  Map<String, dynamic> toUpdateJson() => {
    'institution_id': institutionId,
    'name': name,
    'category': category,
    'description': description,
    'supported_disabilities': supportedDisabilities,
    'price': price,
    'is_free': isFree,
    'duration_minutes': durationMinutes,
    'location_mode': locationMode,
    'booking_type': bookingType,
    'availability_notes': availabilityNotes,
    'is_active': isActive,
  };

  // Copy model with selected changes
  ServiceModel copyWith({
    String? id,
    String? institutionId,
    String? name,
    String? category,
    String? description,
    List<String>? supportedDisabilities,
    double? price,
    bool? isFree,
    int? durationMinutes,
    String? locationMode,
    String? bookingType,
    String? availabilityNotes,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      institutionId: institutionId ?? this.institutionId,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      supportedDisabilities:
      supportedDisabilities ?? this.supportedDisabilities,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      locationMode: locationMode ?? this.locationMode,
      bookingType: bookingType ?? this.bookingType,
      availabilityNotes: availabilityNotes ?? this.availabilityNotes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}