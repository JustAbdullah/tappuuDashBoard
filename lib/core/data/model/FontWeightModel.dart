// lib/models/font_weight_model.dart
class FontWeightModel {
  final int id;
  final int fontId;
  final int weightValue;
  final String weightName;
  final String assetPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FontWeightModel({
    required this.id,
    required this.fontId,
    required this.weightValue,
    required this.weightName,
    required this.assetPath,
    this.createdAt,
    this.updatedAt,
  });

  factory FontWeightModel.fromJson(Map<String, dynamic> json) {
    return FontWeightModel(
      id: json['id'] ?? 0,
      fontId: json['font_id'] ?? 0,
      weightValue: json['weight_value'] ?? 400,
      weightName: json['weight_name'] ?? '',
      assetPath: json['asset_path'] ?? '',
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
      'font_id': fontId,
      'weight_value': weightValue,
      'weight_name': weightName,
      'asset_path': assetPath,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}