class QrCodeModel {
  final String title;
  final String data;

  QrCodeModel({required this.title, required this.data});

  QrCodeModel copyWith({String? title, String? data}) {
    return QrCodeModel(title: title ?? this.title, data: data ?? this.data);
  }
}
