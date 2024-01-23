class CategoryModel {
  final String categoryId;
  final String categoryName;
  final String imageUrl;
  final String categoryDescription;

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.imageUrl,
    required this.categoryDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'imageUrl': imageUrl,
      'categoryDescription': categoryDescription,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      imageUrl: json['imageUrl'],
      categoryDescription: json['categoryDescription'],
    );
  }
}
