class ReviewModel {
  final String productId;
  final String productName;
  final List<dynamic>? reviews;

  ReviewModel({
    required this.productId,
    required this.productName,
    required this.reviews,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'reviews': reviews,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> json) {
    return ReviewModel(
      productId: json['productId'],
      productName: json['productName'],
      reviews: json['reviews'],
    );
  }
}
