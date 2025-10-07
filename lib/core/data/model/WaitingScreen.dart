// lib/core/data/model/WaitingScreen.dart
class WaitingScreen {
  final int? id;
  final String color; // e.g. "#FFFFFF" or "transparent"
  final String imageUrl;

  WaitingScreen({
    this.id,
    required this.color,
    required this.imageUrl,
  });

  factory WaitingScreen.fromJson(Map<String, dynamic> json) {
    return WaitingScreen(
      id: json['id'] is int ? json['id'] as int : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      color: (json['color'] ?? json['colour'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'color': color,
      'image_url': imageUrl,
    };
  }

  WaitingScreen copyWith({int? id, String? color, String? imageUrl}) {
    return WaitingScreen(
      id: id ?? this.id,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
