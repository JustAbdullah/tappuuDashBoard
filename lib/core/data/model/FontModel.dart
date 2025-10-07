// lib/models/font_model.dart
import 'FontWeightModel.dart';

class FontModel {
  final int id;
  final String familyName;
  final bool isActive;
  final List<FontWeightModel> weights;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FontModel({
    required this.id,
    required this.familyName,
    required this.isActive,
    required this.weights,
    this.createdAt,
    this.updatedAt,
  });

  factory FontModel.fromJson(Map<String, dynamic> json) {
    return FontModel(
      id: json['id'] ?? 0,
      familyName: json['family_name'] ?? '',
      isActive: json['is_active'] ?? false,
      weights: List<FontWeightModel>.from(
        (json['weights'] ?? []).map((x) => FontWeightModel.fromJson(x)),
      ),
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
      'family_name': familyName,
      'is_active': isActive,
      'weights': weights.map((weight) => weight.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  FontModel copyWith({
    int? id,
    String? familyName,
    bool? isActive,
    List<FontWeightModel>? weights,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FontModel(
      id: id ?? this.id,
      familyName: familyName ?? this.familyName,
      isActive: isActive ?? this.isActive,
      weights: weights ?? this.weights,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}