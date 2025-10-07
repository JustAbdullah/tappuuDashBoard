import 'PackageType.dart';

class PremiumPackage {
  int? id;
  String name;
  String? slug;
  String? description;
  int durationDays;
  double price;
  String currency;
  bool isActive;
  int sortOrder;
  int? packageTypeId;
  PackageType? type; // علاقة النوع المحمّل من السيرفر

  PremiumPackage({
    this.id,
    required this.name,
    this.slug,
    this.description,
    required this.durationDays,
    required this.price,
    this.currency = 'SYP',
    this.isActive = false,
    this.sortOrder = 0,
    this.packageTypeId,
    this.type,
  });

  factory PremiumPackage.fromJson(Map<String, dynamic> json) {
    return PremiumPackage(
      id: json['id'] as int?,
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      durationDays: (json['duration_days'] ?? 0) is int
          ? json['duration_days']
          : int.parse((json['duration_days'] ?? 0).toString()),
      price: (json['price'] != null) ? double.parse(json['price'].toString()) : 0.0,
      currency: json['currency'] ?? 'SYP',
      isActive: (json['is_active'] == 1 || json['is_active'] == true),
      sortOrder: json['sort_order'] ?? 0,
      packageTypeId: json['package_type_id'] is int ? json['package_type_id'] : (json['package_type_id'] != null ? int.tryParse(json['package_type_id'].toString()) : null),
      type: (json['type'] != null && json['type'] is Map) ? PackageType.fromJson(Map<String, dynamic>.from(json['type'])) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'duration_days': durationDays,
      'price': price,
      'currency': currency,
      'is_active': isActive ? 1 : 0,
      'sort_order': sortOrder,
      'package_type_id': packageTypeId,
    };
  }
}
