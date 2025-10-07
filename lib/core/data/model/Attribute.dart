class Attribute {
  final int id;
  final String name;
  final String type;
  final bool isShared;
  final bool required; // الحقل الجديد
  final List<CategoryRef> categories;
  final List<AttributeOption> options;

  Attribute({
    required this.id,
    required this.name,
    required this.type,
    required this.isShared,
    required this.required,
    required this.categories,
    required this.options,
  });

  static bool _parseBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) {
      final lower = v.toLowerCase();
      return lower == '1' || lower == 'true' || lower == 'yes' || lower == 'on';
    }
    return false;
  }

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      isShared: _parseBool(json['is_shared'] ?? json['isShared']),
      required: _parseBool(json['required']),
      categories: (json['categories'] as List<dynamic>?)
              ?.map((c) => CategoryRef.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      options: (json['options'] as List<dynamic>?)
              ?.map((opt) => AttributeOption.fromJson(opt as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CategoryRef {
  final int id;
  final String name;

  CategoryRef({
    required this.id,
    required this.name,
  });

  factory CategoryRef.fromJson(Map<String, dynamic> json) {
    return CategoryRef(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
    );
  }
}

class AttributeOption {
  final int id;
  final String value;

  AttributeOption({
    required this.id,
    required this.value,
  });

  factory AttributeOption.fromJson(Map<String, dynamic> json) {
    return AttributeOption(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      value: json['value']?.toString() ?? '',
    );
  }
}
