import 'dart:async';
import 'package:babyshophub/Models/cart_model.dart';
import 'package:babyshophub/Models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class ProductDetails extends StatefulWidget {
  // final String productId;
  ProductModel productModel;

  ProductDetails({
    Key? key,
    required this.productModel,
  }) : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  User? user = FirebaseAuth.instance.currentUser;
  double currentRating = 0.0;

  Map<String, dynamic>? productData; // Variable to store product data

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? productStream;

  @override
  void initState() {
    super.initState();
    // Call a function to initialize the stream when the widget is initialized
    fetchProductDetails();
  }

  @override
  void dispose() {
    // Cancel the stream subscription when the widget is disposed
    productStream?.cancel();
    super.dispose();
  }

  Future<void> fetchProductDetails() async {
    try {
      // Get a reference to the product document in Firestore
      DocumentReference<Map<String, dynamic>> productReference =
          FirebaseFirestore.instance
              .collection('Products')
              .doc(widget.productModel.productId);

      // Create a stream subscription
      productStream = productReference.snapshots().listen((snapshot) {
        if (snapshot.exists) {
          setState(() {
            productData = snapshot.data();
            List<dynamic> userRatings = productData!['userRatings'] ?? [];
            if (userRatings.isNotEmpty) {
              double totalRating = userRatings
                  .map((rating) => rating['rating'] ?? 0.0)
                  .reduce((sum, rating) => sum + rating);
              currentRating = totalRating / userRatings.length;
            } else {
              currentRating = 0.0;
            }
          });
        } else {
          print('Document does not exist');
        }
      });
      // Create a stream subscription
      productStream = productReference.snapshots().listen((snapshot) {
        if (snapshot.exists) {
          setState(() {
            productData = snapshot.data();
            List<dynamic> userReviews = productData!['reviews'] ?? [];

            if (userReviews.isNotEmpty) {
              // Concatenate review texts and ratings
              String reviewsAndRatings = userReviews
                  .map((review) =>
                      'Rating: ${review['rating']} - Review: ${review['reviewText']}')
                  .join('\n\n'); // Join with double newline for separation

              // Use the concatenated string as needed (e.g., display in UI)
              print('Reviews and Ratings:\n$reviewsAndRatings');
            } else {
              currentRating = 0.0;
            }
          });
        } else {
          print('Document does not exist');
        }
      });
    } catch (error) {
      print('Error initializing product stream: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color.fromRGBO(87, 213, 236, 1),
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
        centerTitle: true,
        title: const Text(
          "Product Details",
          style: TextStyle(
            color: Color.fromRGBO(87, 213, 236, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Center(
                child: productData != null
                    ? Card(
                        color: Colors.white,
                        elevation: 0,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              // child: SizedBox(
                              //   child: Image.network(
                              //     productData!['imageUrls'].isNotEmpty
                              //         ? productData!['imageUrls'][0]
                              //         : Shimmer.fromColors(
                              //             baseColor: Colors.grey[300]!,
                              //             highlightColor: Colors.grey[100]!,
                              //             child: Container(
                              //               width: 150,
                              //               height: 150,
                              //               color: Colors.white,
                              //             ),
                              //           ),
                              //     width:
                              //         MediaQuery.of(context).size.width * 0.8,
                              //     height:
                              //         MediaQuery.of(context).size.height * 0.4,
                              //     fit: BoxFit.cover,
                              //     loadingBuilder: (BuildContext context,
                              //         Widget child,
                              //         ImageChunkEvent? loadingProgress) {
                              //       if (loadingProgress == null) {
                              //         return child;
                              //       } else {
                              //         // Show a loading indicator or placeholder while retrying
                              //         return Shimmer.fromColors(
                              //           baseColor: Colors.grey[300]!,
                              //           highlightColor: Colors.grey[100]!,
                              //           child: Container(
                              //             width: 150,
                              //             height: 150,
                              //             color: Colors.white,
                              //           ),
                              //         );
                              //       }
                              //     },
                              //   ),
                              // ),
                              child: SizedBox(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: productData!['imageUrls'][0].isNotEmpty
                                      ? Image.network(
                                          productData!['imageUrls'][0]
                                                  .isNotEmpty
                                              ? productData!['imageUrls'][0]
                                              : 'Loading...',
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            } else {
                                              return Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor:
                                                    Colors.grey[100]!,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.4,
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
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.4,
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
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 1,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productData!['productName'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Rs. ${productData!['fullPrice']}',
                                      style: const TextStyle(
                                        color: Color.fromRGBO(87, 213, 236, 1),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Description:',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    Text(
                                      productData!['productDescription'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Card(
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reviews & Rating",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              // width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(
                                '${currentRating.toStringAsFixed(1)} (${productData?['userRatings']?.length ?? 0}) ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                ),
                              ),
                            ),
                            RatingBar.builder(
                              initialRating: currentRating.toDouble(),
                              glowColor: Colors.white,
                              minRating: 0.5,
                              maxRating: 5,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              tapOnlyMode: false,
                              itemCount: 5,
                              itemSize: 30,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              ignoreGestures: true,
                              onRatingUpdate: (value) {},
                            ),
                            const SizedBox(width: 10),
                            Container(
                              color: getRatingColor(getUserRating(user!.uid)),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 2, 10, 2),
                                child: Text(
                                  getRatingMessage(currentRating.toDouble()),
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.035,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     Padding(
                      //       padding: const EdgeInsets.only(bottom: 10.0),
                      //       child: Text(
                      //         'Your Rating: ${getUserRating(user!.uid).toStringAsFixed(1)}',
                      //         style: TextStyle(
                      //           fontSize:
                      //               MediaQuery.of(context).size.width * 0.04,
                      //           fontWeight: FontWeight.w400,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 10),

                      const Divider(),
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: getUserReviews(user!.uid).length,
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Display the total number of reviews
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        RatingBar.builder(
                                          initialRating: getUserRatingreviews(
                                              user!.uid)[index],
                                          glowColor: Colors.white,
                                          minRating: 0.5,
                                          maxRating: 5,
                                          direction: Axis.horizontal,
                                          allowHalfRating: false,
                                          tapOnlyMode: false,
                                          itemCount: 5,
                                          itemSize: 20,
                                          itemPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 0),
                                          itemBuilder: (context, _) =>
                                              const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          ignoreGestures: true,
                                          onRatingUpdate: (value) {},
                                        ),
                                        Text(
                                          DateFormat('dd-MM-yyyy').format(
                                              givenAt(user!.uid)[index]),
                                        ),
                                      ],
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        getUserReviews(user!.uid)[index],
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text("View All"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Card(
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Seller:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                productData?['brand'] ?? '',
                                style: const TextStyle(
                                  color: Color.fromRGBO(87, 213, 236, 1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextButton(
                onPressed: () async {
                  await checkProductExists(uId: user!.uid);

                  Fluttertoast.showToast(
                    msg: "Added to Cart",
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 15.0,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(87, 213, 236, 1),
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1,
                    vertical: MediaQuery.of(context).size.height * 0.025,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String getRatingMessage(double rating) {
    if (rating >= 4.5) {
      return 'Excellent';
    } else if (rating >= 3.5) {
      return 'Good';
    } else if (rating >= 2.5) {
      return 'Average';
    } else if (rating >= 1.5) {
      return 'Poor';
    } else {
      return 'Very Poor';
    }
  }

  Color getRatingColor(double rating) {
    if (rating >= 4.5) {
      return Colors.green;
    } else if (rating >= 3.5) {
      return Colors.lightGreen;
    } else if (rating >= 2.5) {
      return Colors.amber;
    } else if (rating >= 1.5) {
      return Colors.redAccent;
    } else {
      return Colors.red;
    }
  }

//rating
  double calculateAverageRating(List<dynamic> userRatings) {
    if (userRatings.isNotEmpty) {
      double totalRating = userRatings
          .map((rating) => rating['rating'] ?? 0.0)
          .reduce((sum, rating) => sum + rating);
      return totalRating / userRatings.length;
    } else {
      return 0.0;
    }
  }

  double getUserRating(String userId) {
    List<dynamic> userRatings = productData?['userRatings'] ?? [];
    var userRating = userRatings.firstWhere(
      (rating) => rating['userId'] == userId,
      orElse: () => null,
    );
    return userRating != null ? userRating['rating'] : 0.0;
  }

  List<double> getUserRatingreviews(String userId) {
    List<dynamic> userRatings = productData?['userRatings'] ?? [];
    List<double> userReviews = userRatings
        // .where((rating) => rating['userId'] == userId)
        .map<double>((rating) => (rating['rating'] ?? 0).toDouble())
        .toList();
    return userReviews;
  }

  List<String> getUserReviews(String userId) {
    List<dynamic> userRatings = productData?['reviews'] ?? [];
    List<String> userReviews = userRatings
        .map((rating) => (rating['reviewText'] ?? '') as String)
        .toList();

    return userReviews;
  }

  List<DateTime> givenAt(String userId) {
    List<dynamic> userReviews = productData?['reviews'] ?? [];
    List<DateTime> timestamps = userReviews
        .map((review) => (review['givenAt'] as Timestamp).toDate())
        .toList();

    return timestamps;
  }

  //check product exists
  Future<void> checkProductExists({
    required String uId,
    int quantityIncrement = 1,
  }) async {
    final DocumentReference documentReference = FirebaseFirestore.instance
        .collection('Cart')
        .doc(uId)
        .collection('CartOrders')
        .doc(widget.productModel.productId.toString());

    DocumentSnapshot snapshot = await documentReference.get();

    if (snapshot.exists) {
      int currentQuantity = snapshot['productQuantity'];
      int updateQuantity = currentQuantity + quantityIncrement;

      double totalPrice =
          double.parse(widget.productModel.fullPrice) * updateQuantity;

      await documentReference.update({
        'productQuantity': updateQuantity,
        'productTotalPrice': totalPrice,
      });
      print('Product Exists');
    } else {
      await FirebaseFirestore.instance.collection('Cart').doc(uId).set(
        {
          'uId': uId,
          'createdAt': DateTime.now(),
        },
      );

      CartModel cartModel = CartModel(
        productId: widget.productModel.productId,
        productName: widget.productModel.productName,
        fullPrice: widget.productModel.fullPrice,
        imageUrls: widget.productModel.imageUrls,
        productDescription: widget.productModel.productDescription,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        productQuantity: 1,
        productTotalPrice: double.parse(widget.productModel.fullPrice),
      );

      await documentReference.set(cartModel.toMap());

      print('Product Added');
    }
  }
}
