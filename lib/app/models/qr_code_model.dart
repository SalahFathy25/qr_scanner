class QrCodeModel {
  final String title;
  final String data;

  QrCodeModel({required this.title, required this.data});

  QrCodeModel copyWith({String? title, String? data}) {
    return QrCodeModel(title: title ?? this.title, data: data ?? this.data);
  }

  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      title: json['title'] as String,
      data: json['data'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'data': data};
  }
}
