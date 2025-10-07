// lib/models/user_model.dart

class AdvertiserProfile {
  final int id;
  final int userId;
  final String name;
  final String? logo;
  final String? description;
  final String? contactPhone;
  final String? whatsappPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdvertiserProfile({
    required this.id,
    required this.userId,
    required this.name,
    this.logo,
    this.description,
    this.contactPhone,
    this.whatsappPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdvertiserProfile.fromJson(Map<String, dynamic> json) {
    return AdvertiserProfile(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      description: json['description'] as String?,
      contactPhone: json['contact_phone'] as String?,
      whatsappPhone: json['whatsapp_phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class UserModel {
  final int id;
  final String email;
  final String password;
  final DateTime date;
  final bool isDeleted;
  final bool isBlocked;
  final int maxFreePosts;
  final int freePostsUsed;
  final int advertiserProfileCount;
  final int adsCount;
  final AdvertiserProfile? advertiserProfile;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.date,
    required this.isDeleted,
    required this.isBlocked,
    required this.maxFreePosts,
    required this.freePostsUsed,
    required this.advertiserProfileCount,
    required this.adsCount,
    this.advertiserProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      password: json['password'] as String,
      date: DateTime.parse(json['date'] as String),
      isDeleted: (json['is_delete'] as int) == 1,
      isBlocked: (json['is_block'] as int) == 1,
      maxFreePosts: json['max_free_posts'] as int,
      freePostsUsed: json['free_posts_used'] as int,
      advertiserProfileCount: json['advertiser_profile_count'] as int,
      adsCount: json['ads_count'] as int,
      advertiserProfile: json['advertiser_profile'] != null
          ? AdvertiserProfile.fromJson(json['advertiser_profile'])
          : null,
    );
  }
}
