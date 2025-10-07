// lib/models/user_wallet.dart

class UserSummary {
  int? id;
  String? email;
  String? password; // موجود في الاستجابة ولكن غالبًا مش هنستخدمه
  String? date;
  int? isDelete;
  int? isBlock;
  int? maxFreePosts;
  int? freePostsUsed;
  String? signupMethod;

  UserSummary({
    this.id,
    this.email,
    this.password,
    this.date,
    this.isDelete,
    this.isBlock,
    this.maxFreePosts,
    this.freePostsUsed,
    this.signupMethod,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      email: json['email'] as String?,
      password: json['password'] as String?,
      date: json['date'] as String?,
      isDelete: json['is_delete'] is int ? json['is_delete'] : (json['is_delete'] != null ? int.tryParse(json['is_delete'].toString()) : null),
      isBlock: json['is_block'] is int ? json['is_block'] : (json['is_block'] != null ? int.tryParse(json['is_block'].toString()) : null),
      maxFreePosts: json['max_free_posts'] is int ? json['max_free_posts'] : (json['max_free_posts'] != null ? int.tryParse(json['max_free_posts'].toString()) : null),
      freePostsUsed: json['free_posts_used'] is int ? json['free_posts_used'] : (json['free_posts_used'] != null ? int.tryParse(json['free_posts_used'].toString()) : null),
      signupMethod: json['signup_method'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'password': password,
      'date': date,
      'is_delete': isDelete,
      'is_block': isBlock,
      'max_free_posts': maxFreePosts,
      'free_posts_used': freePostsUsed,
      'signup_method': signupMethod,
    };
  }
}

class UserWallet {
  int? id;
  String? uuid;
  int userId;
  double balance;
  String status;
  String currency;
  DateTime? createdAt;
  DateTime? lastChangedAt;
  UserSummary? user;

  UserWallet({
    this.id,
    this.uuid,
    required this.userId,
    required this.balance,
    this.status = 'active',
    this.currency = 'SYP',
    this.createdAt,
    this.lastChangedAt,
    this.user,
  });

  factory UserWallet.fromJson(Map<String, dynamic> json) {
    // بعض السيرفرات تعيد الأرقام كسلاسل؛ نتعامل مع الحالتين
    int parsedUserId = json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString());
    double parsedBalance = 0.0;
    if (json['balance'] != null) {
      parsedBalance = double.tryParse(json['balance'].toString()) ?? 0.0;
    }

    DateTime? created;
    if (json['created_at'] != null) {
      created = DateTime.tryParse(json['created_at'].toString());
    }

    DateTime? lastChanged;
    if (json['last_changed_at'] != null) {
      lastChanged = DateTime.tryParse(json['last_changed_at'].toString());
    }

    return UserWallet(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      uuid: json['uuid'] as String?,
      userId: parsedUserId,
      balance: parsedBalance,
      status: json['status'] as String? ?? 'active',
      currency: json['currency'] as String? ?? 'SYP',
      createdAt: created,
      lastChangedAt: lastChanged,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? UserSummary.fromJson(Map<String, dynamic>.from(json['user']))
          : null,
    );
  }

  static List<UserWallet> listFromJson(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => UserWallet.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      'user_id': userId,
      'balance': balance,
      'status': status,
      'currency': currency,
      'created_at': createdAt?.toIso8601String(),
      'last_changed_at': lastChangedAt?.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}
