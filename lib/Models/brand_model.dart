class BrandModel {
  final String brandId;
  final String brandName;
  final String imageUrl;
  final String brandDescription;

  BrandModel({
    required this.brandId,
    required this.brandName,
    required this.imageUrl,
    required this.brandDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'brandId': brandId,
      'brandName': brandName,
      'imageUrl': imageUrl,
      'brandDescription': brandDescription,
    };
  }

  factory BrandModel.fromMap(Map<String, dynamic> json) {
    return BrandModel(
      brandId: json['brandId'],
      brandName: json['brandName'],
      imageUrl: json['imageUrl'],
      brandDescription: json['brandDescription'],
    );
  }
}
