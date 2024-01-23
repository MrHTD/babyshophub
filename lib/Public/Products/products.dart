import 'package:babyshophub/Public/Products/product_details.dart';
import 'package:babyshophub/Models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';

class Products extends StatelessWidget {
  const Products({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(241, 244, 248, 1),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Products')
            .orderBy('productId')
            .limit(6)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 10,
              child: const Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No products found!"),
            );
          }

          if (snapshot.data != null) {
            return SingleChildScrollView(
              child: Column(
                children: _buildProductRows(context, snapshot.data!.docs),
              ),
            );
          }

          return Container();
        },
      ),
    );
  }

  List<Widget> _buildProductRows(
      BuildContext context, List<QueryDocumentSnapshot> products) {
    List<Widget> rows = [];
    int productsPerRow = 2;

    for (int i = 0; i < products.length; i += productsPerRow) {
      List<ProductModel> rowProducts = [];
      for (int j = i; j < i + productsPerRow && j < products.length; j++) {
        QueryDocumentSnapshot productData = products[j];
        ProductModel productModel = ProductModel(
          productId: productData['productId'] ?? '',
          productName: productData['productName'] ?? '',
          fullPrice: productData['fullPrice'] ?? '',
          productDescription: productData['productDescription'] ?? '',
          imageUrls: productData['imageUrls'] ?? '',
          brand: productData['brand'] ?? '',
          rating: (productData['rating'] ?? 0) is int
              ? (productData['rating'] ?? 0).toDouble()
              : productData['rating'] ?? 0.0,
          userRatings: productData['userRatings'] ?? [],
        );

        if (productModel.productId.isNotEmpty &&
            productModel.productName.isNotEmpty &&
            productModel.fullPrice.isNotEmpty &&
            productModel.imageUrls.isNotEmpty) {
          rowProducts.add(productModel);
        }
      }

      if (rowProducts.isNotEmpty) {
        rows.add(_buildProductRow(context, rowProducts));
      }
    }

    return rows;
  }

  Widget _buildProductRow(BuildContext context, List<ProductModel> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: products
            .map((product) => _buildProductCard(context, product))
            .toList(),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel productModel) {
    return GestureDetector(
      onTap: () {
        navigateToProductDetails(context, productModel);
      },
      child: Card(
        elevation: 0,
        surfaceTintColor: Colors.white,
        color: Colors.white,
        margin: const EdgeInsets.all(1),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.45,
          height: null,
          child: Column(
            children: [
              const SizedBox(height: 5),
              SizedBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: productModel.imageUrls.isNotEmpty
                      ? Image.network(
                          productModel.imageUrls.isNotEmpty
                              ? productModel.imageUrls[0]
                              : 'Loading...',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Shimmer.fromColors(
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
                              );
                            }
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 150,
                                height: 150,
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
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        productModel.productName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                        ),
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RatingBar.builder(
                          initialRating: productModel.rating,
                          glowColor: Colors.white,
                          direction: Axis.horizontal,
                          itemCount: 1,
                          itemSize: 22,
                          itemPadding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.0015),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          ignoreGestures: true,
                          onRatingUpdate: (value) {},
                        ),
                        Text(
                          '${productModel.rating.toStringAsFixed(1)}/5 (${productModel.userRatings?.length ?? 0})',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: MediaQuery.of(context).size.width * 0.036,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        'Rs. ${productModel.fullPrice}',
                        style: const TextStyle(
                          color: Color.fromRGBO(87, 213, 236, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        // textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToProductDetails(
      BuildContext context, ProductModel productModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetails(productModel: productModel),
      ),
    );
  }
}
