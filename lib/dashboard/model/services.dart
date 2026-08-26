class ServiceDetails {
  final String imageUrl;
  final String price;
  final String title;

  const ServiceDetails({
    required this.imageUrl,
    required this.price,
    required this.title,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    return ServiceDetails(
      imageUrl: json['imageUrl'] as String,
      price: json['price'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'imageUrl': imageUrl, 'price': price, 'title': title};
  }

  ServiceDetails copyWith({String? imageUrl, String? price, String? title}) {
    return ServiceDetails(
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      title: title ?? this.title,
    );
  }
}
