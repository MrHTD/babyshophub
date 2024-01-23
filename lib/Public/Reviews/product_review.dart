import 'dart:async';
import 'package:babyshophub/Models/order_model.dart';
import 'package:babyshophub/Public/Order/order_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ProductReview extends StatefulWidget {
  final OrderModel orderModel;

  const ProductReview({Key? key, required this.orderModel}) : super(key: key);

  @override
  State<ProductReview> createState() => _ProductReviewState();
}

class _ProductReviewState extends State<ProductReview> {
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController reviewcontroller = TextEditingController();
  bool hasGivenReview = true;

  double currentRating = 0.0;

  Map<String, dynamic>? productData;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? productStream;

  @override
  void initState() {
    super.initState();
    // Call a function to initialize the stream when the widget is initialized
    fetchProductDetails();
    fetchUserReview();
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
              .doc(widget.orderModel.productId);

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
    } catch (error) {
      print('Error initializing product stream: $error');
    }
  }

  Future<void> fetchUserReview() async {
    try {
      // Get a reference to the product document in Firestore
      DocumentReference<Map<String, dynamic>> productReference =
          FirebaseFirestore.instance
              .collection('Products')
              .doc(widget.orderModel.productId);

      // Get the product document snapshot
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await productReference.get();

      // Check if the document exists
      if (snapshot.exists) {
        setState(() {
          productData = snapshot.data();
          List<dynamic> existingReviews = productData!['reviews'] ?? [];
          if (existingReviews.isNotEmpty) {
            var userReview = existingReviews.firstWhere(
              (review) => review['userId'] == user!.uid,
              orElse: () => null,
            );

            // Update the hasGivenReview variable based on whether the user has given a review
            hasGivenReview = userReview != null;
            if (hasGivenReview) {
              reviewcontroller.text = userReview['reviewText'] ?? '';
            }
          }
        });
      } else {
        print('Document does not exist');
      }
    } catch (error) {
      print('Error fetching user review: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // bool hasGivenReview = productData != null &&
    //     (productData!['reviews'] ?? [])
    //         .any((review) => review['userId'] == user!.uid);
    // Use the orderModel data to display review details
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
      appBar: AppBar(
        surfaceTintColor: const Color.fromRGBO(241, 244, 248, 1),
        centerTitle: true,
        title: const Text(
          "Review Details",
          style: TextStyle(
            color: Color.fromRGBO(87, 213, 236, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Order ID: ${widget.orderModel.orderId}",
                            style: const TextStyle(
                              color: Color.fromRGBO(87, 213, 236, 1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Date & Time: ${_formatTimestamp(widget.orderModel.createdAt)}",
                        maxLines: 2,
                        style: const TextStyle(
                          color: Color.fromRGBO(87, 213, 236, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Image.network(
                              widget.orderModel.imageUrls.isNotEmpty
                                  ? widget.orderModel.imageUrls[0]
                                  : 'placeholder_url',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  child: Text(
                                    widget.orderModel.productName,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  "x ${widget.orderModel.productQuantity}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    "Rs: ${widget.orderModel.productTotalPrice}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ButtonStyle(
                                surfaceTintColor:
                                    MaterialStateProperty.resolveWith((states) {
                                  return Colors.white;
                                }),
                                elevation:
                                    MaterialStateProperty.resolveWith((states) {
                                  return 0.0; // Set elevation to 0.0 to remove shadow
                                }),
                                side:
                                    MaterialStateProperty.resolveWith((states) {
                                  return const BorderSide(
                                    color: Color.fromRGBO(87, 213, 236, 1),
                                    width: 1.0,
                                  );
                                }),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderDetails(
                                        orderModel: widget.orderModel),
                                  ),
                                );
                              },
                              child: const Text(
                                "Details",
                                style: TextStyle(
                                  color: Color.fromRGBO(87, 213, 236, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            widget.orderModel.status,
                            style: const TextStyle(
                              color: Color.fromRGBO(87, 213, 236, 1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Give Product Rating",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RatingBar.builder(
                                initialRating: getUserRating(user!.uid),
                                glowColor: Colors.white,
                                minRating: 0.5,
                                maxRating: 5,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                tapOnlyMode: false,
                                itemCount: 5,
                                itemSize:
                                    MediaQuery.of(context).size.width * 0.12,
                                itemPadding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                ignoreGestures: false,
                                onRatingUpdate: (double value) async {
                                  await updateProductRating(value);
                                }, // Disable interaction with the stars
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              'Your Rating: ${getUserRating(user!.uid).toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Card(
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Give Review",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Material(
                              elevation: 1,
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                controller: reviewcontroller,
                                // readOnly: hasGivenReview,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  labelText: "Enter Review",
                                  fillColor: Color.fromRGBO(241, 244, 248, 1),
                                  filled: true,
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              height: 60.0,
              child: ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Color.fromRGBO(87, 213, 236, 1),
                  ),
                ),
                child: const Text(
                  "Give Review",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  // Call the method to submit the review
                  await submitReview();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    // Convert the Timestamp to a DateTime
    DateTime dateTime = timestamp.toDate();

    // Format the DateTime
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  //submit reviews
  Future<void> submitReview() async {
    try {
      // Get the review text from the controller
      String reviewText = reviewcontroller.text;
      dynamic givenAt = DateTime.now();

      // Check if the review text is not empty
      if (reviewText.isNotEmpty) {
        // Get a reference to the product document in Firestore
        DocumentReference<Map<String, dynamic>> productReference =
            FirebaseFirestore.instance
                .collection('Products')
                .doc(widget.orderModel.productId);

        // Get the current user ID
        String userId = user!.uid;

        // Check if the user has already given a review for this product
        List<dynamic> existingReviews = productData!['reviews'] ?? [];
        bool userReviewed =
            existingReviews.any((review) => review['userId'] == userId);

        if (userReviewed) {
          // Show a message or handle the case where the user has already given a review
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              surfaceTintColor: Colors.white,
              title: const Text(
                'Review Already Given',
                style: TextStyle(
                  color: Color.fromRGBO(87, 213, 236, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                  'You have already given a review for this product.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Create a new review map
          Map<String, dynamic> reviewMap = {
            'userId': userId,
            'reviewText': reviewText,
            'givenAt': givenAt,
            // 'name': name
          };

          // Update the reviews field in the document
          // If 'reviews' field does not exist, it will be created
          await productReference.update({
            'reviews': FieldValue.arrayUnion([reviewMap]),
          });

          Fluttertoast.showToast(
            msg: "Review submitted successfully",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } catch (error) {
      // Handle errors during the review submission process
      print('Error submitting review: $error');
      Fluttertoast.showToast(
        msg: "$error",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  //rating
  Future<void> updateProductRating(double newRating) async {
    try {
      // Get a reference to the product document in Firestore
      DocumentReference<Map<String, dynamic>> productReference =
          FirebaseFirestore.instance
              .collection('Products')
              .doc(widget.orderModel.productId);

      // Get the current user ID
      String userId = user!.uid;

      // Check if the user has already rated the product
      List<dynamic> userRatings = productData!['userRatings'] ?? [];
      bool userRated = userRatings.any((rating) => rating['userId'] == userId);

      if (userRated) {
        // Update the existing user rating
        userRatings = userRatings.map((rating) {
          if (rating['userId'] == userId) {
            return {'userId': userId, 'rating': newRating};
          }
          return rating;
        }).toList();
      } else {
        // Add a new user rating
        userRatings.add({'userId': userId, 'rating': newRating});
      }

      // Update the rating field and userRatings field in the document
      await productReference.update({
        'rating': calculateAverageRating(userRatings),
        'userRatings': userRatings,
      });

      print('Rating updated successfully');
    } catch (error) {
      print('Error updating rating: $error');
    }
  }

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
}
