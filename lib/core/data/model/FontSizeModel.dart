// lib/models/font_size_model.dart
class FontSizeModel {
  final int id;
  final String sizeName;
  final double sizeValue;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FontSizeModel({
    required this.id,
    required this.sizeName,
    required this.sizeValue,
    this.description,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory FontSizeModel.fromJson(Map<String, dynamic> json) {
    return FontSizeModel(
      id: json['id'] ?? 0,
      sizeName: json['size_name'] ?? '',
      sizeValue: (json['size_value'] is int) 
          ? (json['size_value'] as int).toDouble() 
          : (json['size_value'] ?? 0.0).toDouble(),
      description: json['description'],
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'size_name': sizeName,
      'size_value': sizeValue,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  FontSizeModel copyWith({
    int? id,
    String? sizeName,
    double? sizeValue,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FontSizeModel(
      id: id ?? this.id,
      sizeName: sizeName ?? this.sizeName,
      sizeValue: sizeValue ?? this.sizeValue,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}