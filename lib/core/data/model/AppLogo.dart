// lib/core/data/model/AppLogo.dart

class AppLogo {
  final int id;
  final String url;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppLogo({
    required this.id,
    required this.url,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory AppLogo.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      try {
        if (v == null) return null;
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return AppLogo(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      url: json['url']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  AppLogo copyWith({
    int? id,
    String? url,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppLogo(
      id: id ?? this.id,
      url: url ?? this.url,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
