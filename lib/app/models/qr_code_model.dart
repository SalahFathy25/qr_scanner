class QrCodeModel {
  final String id;
  final String title;
  final String data;
  final String category;
  final bool isFavorite;
  final DateTime createdAt;
  final int colorValue;
  final int? gradientStart;
  final int? gradientEnd;
  final bool hasLogo;

  QrCodeModel({
    required this.id,
    required this.title,
    required this.data,
    required this.category,
    this.isFavorite = false,
    DateTime? createdAt,
    this.colorValue = 0xFF000000,
    this.gradientStart,
    this.gradientEnd,
    this.hasLogo = false,
  }) : createdAt = createdAt ?? DateTime.now();

  QrCodeModel copyWith({
    String? id,
    String? title,
    String? data,
    String? category,
    bool? isFavorite,
    DateTime? createdAt,
    int? colorValue,
    int? gradientStart,
    int? gradientEnd,
    bool? hasLogo,
  }) {
    return QrCodeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      data: data ?? this.data,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      colorValue: colorValue ?? this.colorValue,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      hasLogo: hasLogo ?? this.hasLogo,
    );
  }

  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String,
      data: json['data'] as String,
      category: json['category'] as String? ?? 'text',
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      colorValue: json['colorValue'] as int? ?? 0xFF000000,
      gradientStart: json['gradientStart'] as int?,
      gradientEnd: json['gradientEnd'] as int?,
      hasLogo: json['hasLogo'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'data': data,
      'category': category,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'colorValue': colorValue,
      if (gradientStart != null) 'gradientStart': gradientStart,
      if (gradientEnd != null) 'gradientEnd': gradientEnd,
      'hasLogo': hasLogo,
    };
  }
}
