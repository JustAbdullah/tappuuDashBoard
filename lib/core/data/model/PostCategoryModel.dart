// lib/core/data/model/PostCategoryModel.dart
class PostCategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  PostCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory PostCategoryModel.fromJson(Map<String, dynamic> json) {
    return PostCategoryModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != 0) 'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
