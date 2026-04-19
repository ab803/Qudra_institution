class BundleModel {
  final int id;
  final DateTime createdAt;
  final String name;
  final int price;
  final int duration;
  final String status;
  final String description;

  const BundleModel({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.price,
    required this.duration,
    required this.status,
    required this.description,
  });

  factory BundleModel.fromJson(Map<String, dynamic> json) => BundleModel(
    id: json['id'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
    name: json['name'] as String,
    price: json['price'] as int,
    duration: json['duration'] as int,
    status: json['status'] as String,
    description: json['bundle_description'] as String,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'duration': duration,
    'status': status,
    'bundle_description': description,
  };

  BundleModel copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    int? price,
    int? duration,
    String? status,
    String? description,
  }) =>
      BundleModel(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        name: name ?? this.name,
        price: price ?? this.price,
        duration: duration ?? this.duration,
        status: status ?? this.status,
        description: description ?? this.description,
      );
}