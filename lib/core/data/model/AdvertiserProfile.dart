// lib/models/advertiser_profile.dart

class AdvertiserProfile {
  final int? id;
  final int userId;
  final String? logo;
  final String? name;
  final String? description;
  final String? contactPhone;
  final String? whatsappPhone;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User? user; // بيانات المستخدم الأساسية

  AdvertiserProfile({
    this.id,
    required this.userId,
    this.logo,
    this.name,
    this.description,
    this.contactPhone,
    this.whatsappPhone,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvertiserProfile && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory AdvertiserProfile.fromJson(Map<String, dynamic> json) {
    return AdvertiserProfile(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      logo: json['logo'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      contactPhone: json['contact_phone'] as String?,
      whatsappPhone: json['whatsapp_phone'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'user_id': userId,
      'logo': logo,
      'name': name,
      'description': description,
      'contact_phone': contactPhone,
      'whatsapp_phone': whatsappPhone,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  final int id;
  final String email;

  User({
    required this.id,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
      };
}
