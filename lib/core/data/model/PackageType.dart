class PackageType {
  int? id;
  String name;
  String? description;
  String? createdAt;
  String? updatedAt;

  PackageType({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory PackageType.fromJson(Map<String, dynamic> json) {
    return PackageType(
      id: json['id'] as int?,
      name: json['name'] ?? '',
      description: json['description'],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
    };
  }
}
