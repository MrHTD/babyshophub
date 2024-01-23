import 'package:babyshophub/Models/category_model.dart';
import 'package:babyshophub/Public/Products/product_categories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Categories extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const Categories({Key? key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(241, 244, 248, 1),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Categories').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data != null) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: snapshot.data!.docs.map((categoryData) {
                  CategoryModel categoryModel = CategoryModel(
                    categoryId: categoryData['categoryId'] ?? '',
                    categoryName: categoryData['categoryName'] ?? '',
                    categoryDescription:
                        categoryData['categoryDescription'] ?? '',
                    imageUrl: categoryData['imageUrl'] ?? '',
                  );

                  if (categoryModel.categoryId.isEmpty ||
                      categoryModel.categoryName.isEmpty ||
                      categoryModel.categoryDescription.isEmpty ||
                      categoryModel.imageUrl.isEmpty) {
                    // Handle the case where essential data is missing
                    return Container();
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductCategories(categoryModel: categoryModel),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 1,
                      surfaceTintColor: const Color.fromRGBO(253, 253, 253, 1),
                      margin: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 150,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: categoryModel.imageUrl.isNotEmpty
                                    ? Image.network(
                                        categoryModel.imageUrl.isNotEmpty
                                            ? categoryModel.imageUrl
                                            : 'Loading...',
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.contain,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          } else {
                                            return Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  width: 120,
                                                  height: 120,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: 120,
                                              height: 120,
                                            ),
                                          );
                                        },
                                      )
                                    : Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: 150,
                                            height: 150,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: SizedBox(
                                child: Text(
                                  categoryModel.categoryName,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }

          return Container();
        },
      ),
    );
  }
}

void navigateTocategoryDetails(
    BuildContext context, CategoryModel categoryModel) {
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) => categoryDetails(categoryModel: categoryModel),
  //   ),
  // );
}
