import 'dart:convert';

class TocItem {
  final String tag; // h1,h2,...
  final String text;
  final String id;

  TocItem({required this.tag, required this.text, required this.id});

  factory TocItem.fromJson(Map<String, dynamic> j) {
    return TocItem(
      tag: j['tag']?.toString() ?? 'h2',
      text: j['text']?.toString() ?? '',
      id: j['id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'tag': tag, 'text': text, 'id': id};
}

/// نموذج تصنيف المنشور
class PostCategoryModel {
  final int id;
  final String name;
  final String? slug;
  final String? description;

  PostCategoryModel({
    required this.id,
    required this.name,
    this.slug,
    this.description,
  });

  factory PostCategoryModel.fromJson(Map<String, dynamic> json) {
    return PostCategoryModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
      };
}

class Post {
  final int id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? content; // HTML
  final String? featuredImage;
  final String? metaTitle;
  final String? metaDescription;
  final String status;
  final String? publishedAt;
  final String? createdAt;
  final String? updatedAt;
  final List<TocItem>? toc;
  final PostCategoryModel? category; // تم إضافة حقل التصنيف

  Post({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    this.content,
    this.featuredImage,
    this.metaTitle,
    this.metaDescription,
    required this.status,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.toc,
    this.category, // تم إضافة التصنيف هنا
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      excerpt: json['excerpt']?.toString(),
      content: json['content']?.toString(),
      featuredImage: _parseFeaturedImage(json),
      metaTitle: json['meta_title'] ?? json['metaTitle']?.toString(),
      metaDescription: json['meta_description'] ?? json['metaDescription']?.toString(),
      status: json['status']?.toString() ?? 'draft',
      publishedAt: json['published_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      toc: _parseToc(json),
      category: _parseCategory(json), // تم إضافة parsing التصنيف
    );
  }

  static PostCategoryModel? _parseCategory(Map<String, dynamic> json) {
    try {
      final c = json['category'] ?? json['post_category'] ?? json['category_id'];
      if (c == null) return null;
      
      if (c is Map<String, dynamic>) {
        return PostCategoryModel.fromJson(Map<String, dynamic>.from(c));
      } else if (c is int) {
        // إذا كان category مجرد ID، نعيد نموذج أساسي
        return PostCategoryModel(
          id: c,
          name: 'التصنيف $c',
        );
      } else if (c is String) {
        // إذا كان category نص، نحاول تحويله لرقم
        final id = int.tryParse(c);
        if (id != null) {
          return PostCategoryModel(
            id: id,
            name: 'التصنيف $id',
          );
        }
      }
    } catch (e) {
      print('Error parsing category: $e');
    }
    return null;
  }

  static List<TocItem>? _parseToc(Map<String, dynamic> json) {
    final t = json['toc'] ?? json['table_of_contents'];
    if (t == null) return null;
    if (t is String) {
      try {
        final decoded = jsonDecode(t);
        if (decoded is List) {
          return decoded.map((e) {
            if (e is Map<String, dynamic>) return TocItem.fromJson(e);
            return TocItem.fromJson(Map<String, dynamic>.from(e));
          }).toList();
        }
      } catch (_) {
        return null;
      }
    } else if (t is List) {
      return t.map((e) {
        if (e is Map<String, dynamic>) return TocItem.fromJson(Map<String, dynamic>.from(e));
        return TocItem.fromJson(Map<String, dynamic>.from(e as Map));
      }).toList();
    }
    return null;
  }

  static String? _parseFeaturedImage(Map<String, dynamic> json) {
    if (json['featured_image'] is String) return json['featured_image'];
    if (json['featured_image'] is Map) {
      final m = Map<String, dynamic>.from(json['featured_image']);
      return (m['url'] ?? m['path'] ?? m['src'])?.toString();
    }
    if (json['featuredImage'] is String) return json['featuredImage'];
    if (json['image'] is String) return json['image'];
    if (json['image'] is Map) {
      final m = Map<String, dynamic>.from(json['image']);
      return (m['url'] ?? m['path'])?.toString();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'excerpt': excerpt,
      'content': content,
      'featured_image': featuredImage,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'status': status,
      'published_at': publishedAt,
      'toc': toc?.map((e) => e.toJson()).toList(),
      'category': category?.toJson(), // تم إضافة التصنيف في الـ toJson
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}