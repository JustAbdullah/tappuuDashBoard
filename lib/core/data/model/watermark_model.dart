


class WatermarkModel {
  final int? id;
  final String keyName;        // 'watermark'
  final bool isImage;          // هل النمط صورة؟
  final String? imageUrl;      // رابط صورة العلامة عند isImage=true

  // نمط النص (عند isImage=false)
  final String? textContent;   // قد تكون null عندما النمط صورة
  final String? fontUrl;
  final int? fontSize;         // px — قد تكون null
  final String? color;         // Hex مثل #000000 — قد تكون null

  // إعدادات عامة جديدة
  final double? wmImgScale;    // نسبة من عرض الصورة الأصلية (0.08..0.35)
  final int? wmOpacity;        // شفافية % (0..100)

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WatermarkModel({
    this.id,
    required this.keyName,
    required this.isImage,
    this.imageUrl,
    this.textContent,
    this.fontUrl,
    this.fontSize,
    this.color,
    this.wmImgScale,
    this.wmOpacity,
    this.createdAt,
    this.updatedAt,
  });

  factory WatermarkModel.fromJson(Map<String, dynamic> json) {
    double? _scale;
    final rawScale = json['wm_img_scale'];
    if (rawScale != null) {
      if (rawScale is num) {
        _scale = rawScale.toDouble();
      } else {
        _scale = double.tryParse('$rawScale');
      }
    }

    int? _opacity;
    final rawOpacity = json['wm_opacity'];
    if (rawOpacity != null) {
      if (rawOpacity is num) {
        _opacity = rawOpacity.toInt();
      } else {
        _opacity = int.tryParse('$rawOpacity');
      }
    }

    return WatermarkModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      keyName: (json['key_name'] ?? json['keyName'] ?? 'watermark').toString(),
      isImage: (json['is_image'] is bool)
          ? json['is_image'] as bool
          : (json['is_image'] is num ? (json['is_image'] as num) != 0 : false),
      imageUrl: json['image_url']?.toString(),

      textContent: json['text_content']?.toString(),
      fontUrl: json['font_url']?.toString(),
      fontSize: (json['font_size'] is int)
          ? json['font_size'] as int
          : int.tryParse('${json['font_size']}'),
      color: json['color']?.toString(),

      wmImgScale: _scale,
      wmOpacity: _opacity,

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'key_name': keyName,
      'is_image': isImage,
      'image_url': imageUrl,
      'text_content': textContent,
      'font_url': fontUrl,
      'font_size': fontSize,
      'color': color,
      'wm_img_scale': wmImgScale,
      'wm_opacity': wmOpacity,
    };
  }

  WatermarkModel copyWith({
    int? id,
    String? keyName,
    bool? isImage,
    String? imageUrl,
    String? textContent,
    String? fontUrl,
    int? fontSize,
    String? color,
    double? wmImgScale,
    int? wmOpacity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WatermarkModel(
      id: id ?? this.id,
      keyName: keyName ?? this.keyName,
      isImage: isImage ?? this.isImage,
      imageUrl: imageUrl ?? this.imageUrl,
      textContent: textContent ?? this.textContent,
      fontUrl: fontUrl ?? this.fontUrl,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      wmImgScale: wmImgScale ?? this.wmImgScale,
      wmOpacity: wmOpacity ?? this.wmOpacity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}