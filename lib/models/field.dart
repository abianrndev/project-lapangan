class Field {
  final int? id;
  final String name;
  final String description;
  final int pricePerHour;
  final String imageUrl;
  final bool isAvailable;
  final DateTime? createdAt;

  Field({
    this.id,
    required this.name,
    required this.description,
    required this.pricePerHour,
    required this.imageUrl,
    this.isAvailable = true,
    this.createdAt,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price_per_hour': pricePerHour,
      'image_url': imageUrl,
      'is_available': isAvailable ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create Field from Map
  factory Field.fromMap(Map<String, dynamic> map) {
    return Field(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      pricePerHour: map['price_per_hour'] as int,
      imageUrl: map['image_url'] as String,
      isAvailable: (map['is_available'] as int) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  // Legacy support for old JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id?.toString() ?? '',
      'name': name,
      'description': description,
      'price': pricePerHour.toDouble(),
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      name: json['name'],
      description: json['description'],
      pricePerHour: json['price'] is double
          ? (json['price'] as double).toInt()
          : json['price'],
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  // Create a copy with modified fields
  Field copyWith({
    int? id,
    String? name,
    String? description,
    int? pricePerHour,
    String? imageUrl,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return Field(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper getter for legacy support
  double get price => pricePerHour.toDouble();
}

