class ProductModel {
  final String productId;
  // final String categoryId;
  final String productName;
  // final String categoryName;
  // final String salePrice;
  final List imageUrls;
  // final String deliveryTime;
  // final bool isSale;
  final String productDescription;
  final String fullPrice;
  final String brand;
  final double rating;
  final List<dynamic>? userRatings;

  ProductModel({
    required this.productId,
    required this.productName,
    required this.fullPrice,
    required this.imageUrls,
    required this.productDescription,
    required this.brand,
    required this.rating,
    required this.userRatings,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'fullPrice': fullPrice,
      'imageUrls': imageUrls,
      'brand': brand,
      'productDescription': productDescription,
      'rating': rating,
      'userRatings': userRatings,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'],
      productName: json['productName'],
      fullPrice: json['fullPrice'],
      imageUrls: json['imageUrls'],
      productDescription: json['productDescription'],
      brand: json['brand'],
      rating: json['rating'],
      userRatings: json['userRatings'],
    );
  }
}
