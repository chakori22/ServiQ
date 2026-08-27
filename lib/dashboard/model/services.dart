class ServiceDetails {
  static const int defaultCount = 1;
  static const int countStep = 1;

  final String imageUrl;
  final String price;
  final String title;
  final bool isSelected;
  final int count;

  const ServiceDetails({
    required this.imageUrl,
    required this.price,
    required this.title,
    this.isSelected = false,
    this.count = defaultCount,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    return ServiceDetails(
      imageUrl: json['imageUrl'] as String,
      price: json['price'] as String,
      title: json['title'] as String,
      isSelected: json['isSelected'] as bool? ?? false,
      count: json['count'] as int? ?? defaultCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'price': price,
      'title': title,
      'isSelected': isSelected,
      'count': count,
    };
  }

  ServiceDetails copyWith({
    String? imageUrl,
    String? price,
    String? title,
    bool? isSelected,
    int? count,
  }) {
    return ServiceDetails(
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      title: title ?? this.title,
      isSelected: isSelected ?? this.isSelected,
      count: count ?? this.count,
    );
  }
}
