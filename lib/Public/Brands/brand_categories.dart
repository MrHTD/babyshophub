import 'package:babyshophub/Models/brand_model.dart';
import 'package:babyshophub/Models/product_model.dart';
import 'package:babyshophub/Public/Products/product_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class BrandCategories extends StatefulWidget {
  BrandModel brandModel;

  BrandCategories({Key? key, required this.brandModel}) : super(key: key);

  @override
  State<BrandCategories> createState() => BrandCategoriesState();
}

class BrandCategoriesState extends State<BrandCategories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: const Color.fromRGBO(241, 244, 248, 1),
        title: const Text(
          "Product By Brand",
          style: TextStyle(
              color: Color.fromRGBO(87, 213, 236, 1),
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color.fromRGBO(87, 213, 236, 1),
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Showing Products of: ${widget.brandModel.brandName}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Products')
                    .where('brand', isEqualTo: widget.brandModel.brandName)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Error"),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No products found for this category!"),
                    );
                  }

                  return Column(
                    children: _buildProductRows(context, snapshot.data!.docs),
                  );
                },
              ),
            ],
          ),
        ),
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: GestureDetector(
        onTap: () {
          navigateToProductDetails(context, productModel);
        },
        child: Card(
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(10.0),
          //   side: BorderSide(
          //     color: Color.fromRGBO(241, 244, 248, 1),
          //     width: 1.0,
          //   ),
          // ),
          elevation: 0,
          surfaceTintColor: Colors.white,
          color: Colors.white,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            height: null,
            child: Column(
              children: [
                const SizedBox(height: 5),
                SizedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: productModel.imageUrls.isNotEmpty
                        ? Image.network(
                            productModel.imageUrls[0],
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  color: Colors.white, // or any color you want
                                ),
                              );
                            },
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    color: Colors.white,
                                  ),
                                );
                              }
                            },
                          )
                        : Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 150,
                              height: 150,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
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
                          maxLines: 3,
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
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.036,
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
