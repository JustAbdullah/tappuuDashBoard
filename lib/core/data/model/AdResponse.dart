// ad_models.dart
// نماذج البيانات للـ Ads (محدثة ومحصنة ضد الأخطاء)

int? _nullableIntFromDynamic(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

double? _nullableDoubleFromDynamic(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

/// ==== دالة مساعدة لتحويل أي تمثيل للتاريخ إلى DateTime بشكل آمن ====
DateTime? _nullableDateTimeFromDynamic(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is int) {
    final value = v;
    if (value.abs() < 100000000000) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    } else {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
  }
  if (v is double) {
    final asInt = v.toInt();
    if (asInt.abs() < 100000000000) {
      return DateTime.fromMillisecondsSinceEpoch(asInt * 1000);
    } else {
      return DateTime.fromMillisecondsSinceEpoch(asInt);
    }
  }
  if (v is String) {
    final parsed = DateTime.tryParse(v);
    if (parsed != null) return parsed;
    final digits = int.tryParse(v);
    if (digits != null) {
      if (digits.abs() < 100000000000) return DateTime.fromMillisecondsSinceEpoch(digits * 1000);
      return DateTime.fromMillisecondsSinceEpoch(digits);
    }
    try {
      return DateTime.parse(v.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }
  return null;
}

class AdResponse {
  final int currentPage;
  final int perPage;
  final int total;
  final List<Ad> data;

  AdResponse({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.data,
  });

  factory AdResponse.fromJson(Map<String, dynamic> json) {
    return AdResponse(
      currentPage: (json['current_page'] as int?) ?? 1,
      perPage: (json['per_page'] as int?) ?? 15,
      total: (json['total'] as int?) ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => e is Map<String, dynamic> ? Ad.fromJson(e) : Ad.empty())
              .toList() ?? [],
    );
  }
}

class Ad {
  final int id;
  final int userId;
  final int idAdvertiser;
  final bool is_premium;
  final String status;
  final int views;
  final String ad_number;
  final UserModel user;

  // المحتوى
  final String title;
  final String description;

  // SEO / routing fields (جديدة)
  final String? slug;
  final String? meta_title;
  final String? meta_description;

  final double? price;
  final double? latitude;
  final double? longitude;
  final int? areaId;

  final CategoryModel category;
  final SubCategoryModel subCategoryLevelOne;
  final SubCategoryModel? subCategoryLevelTwo;
  final City? city;
  final Advertiser advertiser;

  final List<String> images;
  final List<String> videos;

  final List<AttributeValue> attributes;
  final DateTime createdAt;

  // الحقول الجديدة الاختيارية (nullable)
  final int? inquirers_count;
  final int? favorites_count;

  // حقل المنطقة المختار: كائن area يحتوي id و name (nullable)
  final Area? area;
final int? show_time;

  // تاريخ انتهاء البريميوم (nullable)
  final DateTime? premiumExpiresAt;

  Ad({
    required this.id,
    required this.userId,
    required this.idAdvertiser,
    required this.ad_number,
    required this.is_premium,
    required this.status,
    required this.views,
    required this.title,
    required this.description,
    required this.user,
    required this.category,
    required this.subCategoryLevelOne,
    required this.advertiser,
    required this.images,
    required this.videos,
    required this.attributes,
    required this.createdAt,
    this.slug,
    this.meta_title,
    this.meta_description,
    this.price,
    this.latitude,
    this.longitude,
    this.areaId,
    this.subCategoryLevelTwo,
    this.city,
    this.inquirers_count,
    this.favorites_count,
    this.area,
    this.premiumExpiresAt,    
    this.show_time,

  });

  // منشئ للإعلان الفارغ
  factory Ad.empty() {
    return Ad(
      id: 0,
      userId: 0,
      idAdvertiser: 0,
      ad_number: "0",
      is_premium: false,
      status: '',
      views: 0,
      title: '',
      show_time: 0,
      description: '',
      user: UserModel(id: 0, email: ''),
      category: CategoryModel(id: 0, name: ''),
      subCategoryLevelOne: SubCategoryModel(id: 0, name: ''),
      advertiser: Advertiser(
        description: '',
        logo: '',
        contactPhone: '',
        whatsappPhone: '',
      ),
      images: [],
      videos: [],
      attributes: [],
      createdAt: DateTime.now(),
    );
  }

  factory Ad.fromJson(Map<String, dynamic> json) {
    try {
      // معالجة user بشكل آمن
      UserModel user;
      try {
        user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
      } catch (e) {
        user = UserModel(id: 0, email: '');
      }

      // معالجة category بشكل آمن
      CategoryModel category;
      try {
        category = CategoryModel.fromJson(json['category'] as Map<String, dynamic>);
      } catch (e) {
        category = CategoryModel(id: 0, name: '');
      }

      // معالجة subCategoryLevelOne بشكل آمن
      SubCategoryModel subCategoryLevelOne;
      try {
        subCategoryLevelOne = SubCategoryModel.fromJson(json['sub_category_level_one'] as Map<String, dynamic>);
      } catch (e) {
        subCategoryLevelOne = SubCategoryModel(id: 0, name: '');
      }

      // معالجة subCategoryLevelTwo بشكل آمن
      SubCategoryModel? subCategoryLevelTwo;
      try {
        if (json['sub_category_level_two'] != null) {
          subCategoryLevelTwo = SubCategoryModel.fromJson(json['sub_category_level_two'] as Map<String, dynamic>);
        }
      } catch (e) {
        subCategoryLevelTwo = null;
      }

      // معالجة city بشكل آمن
      City? city;
      try {
        if (json['city'] != null) {
          city = City.fromJson(json['city'] as Map<String, dynamic>);
        }
      } catch (e) {
        city = null;
      }

      // معالجة advertiser بشكل آمن
      Advertiser advertiser;
      try {
        advertiser = Advertiser.fromJson(json['advertiser'] as Map<String, dynamic>);
      } catch (e) {
        advertiser = Advertiser(
          description: '',
          logo: '',
          contactPhone: '',
          whatsappPhone: '',
        );
      }

      // معالجة area بشكل آمن
      Area? area;
      try {
        if (json['area'] is Map<String, dynamic>) {
          area = Area.fromJson(json['area'] as Map<String, dynamic>);
        } else {
          final dynamic areaNameRaw = json['area_name'] ?? json['areaName'];
          final dynamic areaIdRaw = json['area_id'] ?? json['areaId'];

          final int? parsedAreaId = _nullableIntFromDynamic(areaIdRaw);
          final String? parsedAreaName = areaNameRaw?.toString();

          if (parsedAreaId != null || (parsedAreaName != null && parsedAreaName.isNotEmpty)) {
            area = Area(id: parsedAreaId, name: parsedAreaName);
          }
        }
      } catch (e) {
        area = null;
      }

      // معالجة attributes بشكل آمن
      List<AttributeValue> attributes = [];
      try {
        if (json['attributes'] is List) {
          attributes = (json['attributes'] as List).map((e) {
            try {
              return AttributeValue.fromJson(e as Map<String, dynamic>);
            } catch (_) {
              return AttributeValue(name: '', value: '');
            }
          }).toList();
        }
      } catch (e) {
        attributes = [];
      }

      // معالجة images بشكل آمن
      List<String> images = [];
      try {
        if (json['images'] is List) {
          images = (json['images'] as List).map((e) => e?.toString() ?? '').toList();
        }
      } catch (e) {
        images = [];
      }

      // معالجة videos بشكل آمن
      List<String> videos = [];
      try {
        if (json['videos'] is List) {
          videos = (json['videos'] as List).map((e) => e?.toString() ?? '').toList();
        }
      } catch (e) {
        videos = [];
      }

      return Ad(
        id: _nullableIntFromDynamic(json['id']) ?? 0,
        userId: _nullableIntFromDynamic(json['user_id']) ?? 0,
        idAdvertiser: _nullableIntFromDynamic(json['advertiser_profile_id']) ?? 0,
        ad_number: (json['ad_number']?.toString()) ?? "0",
        is_premium: (json['is_premium'] as bool?) ?? false,
        status: (json['status'] as String?) ?? '',
        views: _nullableIntFromDynamic(json['views']) ?? 0,
        title: (json['title'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
        user: user,
        slug: (json['slug'] as String?),
        meta_title: (json['meta_title'] as String?),
        meta_description: (json['meta_description'] as String?),
        price: _nullableDoubleFromDynamic(json['price']),
        latitude: _nullableDoubleFromDynamic(json['latitude']),
        longitude: _nullableDoubleFromDynamic(json['longitude']),
        areaId: _nullableIntFromDynamic(json['area_id']),
        category: category,
        subCategoryLevelOne: subCategoryLevelOne,
        subCategoryLevelTwo: subCategoryLevelTwo,
        city: city,
        advertiser: advertiser,
        images: images,
        videos: videos,
        attributes: attributes,
        createdAt: _nullableDateTimeFromDynamic(json['created_at']) ?? DateTime.now(),
        inquirers_count: _nullableIntFromDynamic(json['inquirers_count']),
        favorites_count: _nullableIntFromDynamic(json['favorites_count']),
        area: area,
        premiumExpiresAt: _nullableDateTimeFromDynamic(json['premium_expires_at'] ?? json['premiumExpiresAt']),
          show_time:(json['show_time'] as int?) ?? _nullableIntFromDynamic(json['show_time']) ?? 0,

    
      );
    } catch (e) {
      print('Error parsing Ad: $e');
      return Ad.empty();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'advertiser_profile_id': idAdvertiser,
      'ad_number': ad_number,
      'is_premium': is_premium,
      'status': status,
      'views': views,
      'title': title,
      'description': description,
      'slug': slug,
      'meta_title': meta_title,
      'meta_description': meta_description,
      'price': price,
      'latitude': latitude,
      'longitude': longitude,
      'area_id': areaId,
      'category': {'id': category.id, 'name': category.name},
      'sub_category_level_one': {'id': subCategoryLevelOne.id, 'name': subCategoryLevelOne.name},
      'sub_category_level_two': subCategoryLevelTwo != null ? {'id': subCategoryLevelTwo!.id, 'name': subCategoryLevelTwo!.name} : null,
      'city': city != null ? {'id': city!.id, 'slug': city!.slug, 'name': city!.name} : null,
      'advertiser': {
        'name': advertiser.name,
        'description': advertiser.description,
        'logo': advertiser.logo,
        'contact_phone': advertiser.contactPhone,
        'whatsapp_phone': advertiser.whatsappPhone,
        'account_type': advertiser.accountType,
        "show_time": show_time
      },
      'images': images,
      'videos': videos,
      'attributes': attributes.map((a) => {'name': a.name, 'value': a.value}).toList(),
      'created_at': createdAt.toIso8601String(),
      'inquirers_count': inquirers_count,
      'favorites_count': favorites_count,
      'area': area?.toJson(),
      'premium_expires_at': premiumExpiresAt?.toIso8601String(),
    };
  }
}

class CategoryModel {
  final int id;
  final String name;

  CategoryModel({
    required this.id,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _nullableIntFromDynamic(json['id']) ?? 0,
      name: (json['name'] as String?) ?? '',
    );
  }
}

class SubCategoryModel {
  final int id;
  final String name;

  SubCategoryModel({
    required this.id,
    required this.name,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: _nullableIntFromDynamic(json['id']) ?? 0,
      name: (json['name'] as String?) ?? '',
    );
  }
}

class City {
  final int id;
  final String slug;
  final String name;

  City({
    required this.id,
    required this.slug,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: _nullableIntFromDynamic(json['id']) ?? 0,
      slug: (json['slug'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
    );
  }
}

class Advertiser {
  final String? name;
  final String description;
  final String logo;
  final String contactPhone;
  final String whatsappPhone;
  final String accountType;

  static const String TYPE_INDIVIDUAL = 'individual';
  static const String TYPE_COMPANY = 'company';
  
  Advertiser({
    this.name,
    required this.description,
    required this.logo,
    required this.contactPhone,
    required this.whatsappPhone,
    String? accountType,
  }) : accountType = (accountType == null || accountType.isEmpty)
            ? TYPE_INDIVIDUAL
            : accountType;

  factory Advertiser.fromJson(Map<String, dynamic> json) {
    return Advertiser(
      name: json['name'] as String?,
      description: (json['description'] as String?) ?? '',
      logo: (json['logo'] as String?) ?? '',
      contactPhone: (json['contact_phone'] as String?) ?? '',
      whatsappPhone: (json['whatsapp_phone'] as String?) ?? '',
      accountType: (json['account_type'] ?? json['accountType'] ?? TYPE_INDIVIDUAL).toString(),
    );
  }
}

class AttributeValue {
  final String name;
  final String value;

  AttributeValue({
    required this.name,
    required this.value,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> json) {
    return AttributeValue(
      name: (json['name'] as String?) ?? '',
      value: (json['value'] as String?) ?? '',
    );
  }
}

class UserModel {
  final int id;
  final String email;

  UserModel({
    required this.id,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _nullableIntFromDynamic(json['id']) ?? 0,
      email: (json['email'] as String?) ?? '',
    );
  }
}

class Area {
  final int? id;
  final String? name;

  Area({this.id, this.name});

  factory Area.fromJson(Map<String, dynamic> json) {
    final int? id = _nullableIntFromDynamic(json['id'] ?? json['area_id'] ?? json['areaId']);
    final String? name = (json['name'] ?? json['area_name'] ?? json['areaName'])?.toString();
    return Area(id: id, name: name);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}