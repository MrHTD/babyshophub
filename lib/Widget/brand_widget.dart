import 'package:babyshophub/Models/brand_model.dart';
import 'package:babyshophub/Public/Brands/brand_categories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Brands extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const Brands({Key? key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(241, 244, 248, 1),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Brands').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data != null) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: snapshot.data!.docs.map((brandData) {
                  BrandModel brandModel = BrandModel(
                    brandId: brandData['brandId'] ?? '',
                    brandName: brandData['brandName'] ?? '',
                    brandDescription: brandData['brandDescription'] ?? '',
                    imageUrl: brandData['imageUrl'] ?? '',
                  );

                  if (brandModel.brandId.isEmpty ||
                      brandModel.brandName.isEmpty ||
                      brandModel.brandDescription.isEmpty ||
                      brandModel.imageUrl.isEmpty) {
                    // Handle the case where essential data is missing
                    return Container();
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BrandCategories(brandModel: brandModel),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 1,
                      surfaceTintColor: Colors.white,
                      color: Colors.white,
                      margin: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 120,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: brandModel.imageUrl.isNotEmpty
                                    ? Image.network(
                                        brandModel.imageUrl.isNotEmpty
                                            ? brandModel.imageUrl
                                            : 'Loading...',
                                        width: 100,
                                        height: 50,
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
                                                  width: 100,
                                                  height: 50,
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
                                              width: 150,
                                              height: 50,
                                            ),
                                          );
                                        },
                                      )
                                    : Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: 100,
                                          height: 50,
                                          color: Colors
                                              .white, // or any color you want
                                        ),
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
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 10,
              child: const Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No products found!"),
            );
          }
          return Container();
        },
      ),
    );
  }
}

void navigateToBrandDetails(BuildContext context, BrandModel brandModel) {
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) => BrandDetails(brandModel: brandModel),
  //   ),
  // );
}
