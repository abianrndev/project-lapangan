import 'dart:io';
import 'package:flutter/material.dart';

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
      imageUrl: map['image_url'] as String? ?? '',
      isAvailable: (map['is_available'] as int?) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  // Legacy JSON support
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
      imageUrl: json['imageUrl'] ?? '',
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

  // Helper getters
  double get price => pricePerHour.toDouble();
  bool get isLocalImage => imageUrl.isNotEmpty && !imageUrl.startsWith('http');
  bool get hasValidImage => imageUrl.isNotEmpty;

  // Get appropriate image widget based on image type
  Widget getImageWidget({
    double? width,
    double? height,
    BoxFit? fit,
    Widget? errorWidget,
    Widget? placeholderWidget,
    bool showDebug = false,
  }) {
    if (showDebug) {
      print('🖼️ getImageWidget called for:  $name');
      print('📍 Image path: $imageUrl');
      print('📁 Is local image: $isLocalImage');
      print('✅ Has valid image: $hasValidImage');
    }

    // Default error widget
    final defaultErrorWidget =
        errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey[600], size: 32),
              const SizedBox(height: 8),
              Text(
                'Gagal memuat gambar',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
              if (showDebug) ...[
                const SizedBox(height: 4),
                Text(
                  imageUrl,
                  style: const TextStyle(color: Colors.red, fontSize: 8),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );

    // Default placeholder widget
    final defaultPlaceholderWidget =
        placeholderWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[100],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, color: Colors.grey[400], size: 32),
              const SizedBox(height: 8),
              Text(
                'Belum ada foto',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );

    // If no image URL provided
    if (!hasValidImage) {
      if (showDebug) print('❌ No valid image URL');
      return defaultPlaceholderWidget;
    }

    // Local file image
    if (isLocalImage) {
      final file = File(imageUrl);
      final fileExists = file.existsSync();

      if (showDebug) {
        print('📁 Checking file exists: $fileExists');
        print('📁 Full path: ${file.absolute.path}');
      }

      // Check if file exists
      if (!fileExists) {
        if (showDebug) print('❌ File does not exist');
        return defaultErrorWidget;
      }

      if (showDebug) print('✅ Showing local image');
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          file,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (showDebug) print('❌ Error loading local image:  $error');
            return defaultErrorWidget;
          },
        ),
      );
    }
    // Network image
    else {
      if (showDebug) print('🌐 Showing network image');
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            if (showDebug) print('❌ Error loading network image: $error');
            return defaultErrorWidget;
          },
        ),
      );
    }
  }

  // Get thumbnail widget (smaller version)
  Widget getThumbnailWidget({
    double size = 60,
    BoxFit? fit,
    bool showDebug = false,
  }) {
    return getImageWidget(
      width: size,
      height: size,
      fit: fit ?? BoxFit.cover,
      showDebug: showDebug,
    );
  }

  // Get hero image widget (full screen preview)
  Widget getHeroImageWidget({bool showDebug = false}) {
    return InteractiveViewer(
      child: getImageWidget(
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        showDebug: showDebug,
      ),
    );
  }
}
