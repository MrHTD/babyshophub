import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class MyReviews extends StatefulWidget {
  const MyReviews({Key? key}) : super(key: key);

  @override
  State<MyReviews> createState() => _MyReviewsState();
}

class _MyReviewsState extends State<MyReviews> {
  User? user = FirebaseAuth.instance.currentUser;

  Future<List<Widget>> getProductData() async {
    // Reference to the 'Products' collection
    CollectionReference productsCollection =
        FirebaseFirestore.instance.collection('Products');

    // Get products with reviews by the current user
    QuerySnapshot querySnapshot = await productsCollection
        .where('reviews', isNotEqualTo: null)
        // .orderBy('productName', descending: true)
        .get();

    // Extract data from each document
    List<Widget> productsWidgets = [];

    for (DocumentSnapshot doc in querySnapshot.docs) {
      String productName = doc['productName'];
      String fullPrice = doc['fullPrice'];
      List imageUrls = doc['imageUrls'];

      List<dynamic>? reviews = doc['reviews'];
      List<dynamic> userReviews =
          reviews?.where((review) => review['userId'] == user!.uid).toList() ??
              [];

      // Skip products without reviews from the current user
      if (userReviews.isEmpty) {
        continue;
      }

      // Fetch other product details
      productsWidgets.add(
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Card(
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                splashColor: const Color.fromRGBO(87, 213, 236, 0.4),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var review in userReviews)
                        if (review['givenAt'] != null)
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "Date: ${_formatTimestamp(review['givenAt'] as Timestamp)}",
                              style: const TextStyle(
                                color: Color.fromRGBO(87, 213, 236, 1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      Card(
                        elevation: 0,
                        color: const Color.fromRGBO(241, 244, 248, 1),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              SizedBox(
                                child: ClipRRect(
                                  child: imageUrls.isNotEmpty
                                      ? Image.network(
                                          imageUrls[0],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors
                                                    .white, // or any color you want
                                              ),
                                            );
                                          },
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
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        )
                                      : Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Text(
                                        productName,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text("Rs: $fullPrice"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Your Review:",
                              style: TextStyle(
                                color: Color.fromRGBO(87, 213, 236, 1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Card(
                              color: const Color.fromRGBO(241, 244, 248, 1),
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    for (var review in userReviews)
                                      if (review['reviewText'] != null)
                                        Text(
                                          "${review['reviewText']}",
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return productsWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
      appBar: AppBar(
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
        title: const Text(
          "My Reviews",
          style: TextStyle(
            color: Color.fromRGBO(87, 213, 236, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder(
        future: getProductData(),
        builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Display user reviews for products
                  ...snapshot.data!,
                ],
              ),
            );
          }
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    // Convert the Timestamp to a DateTime
    DateTime dateTime = timestamp.toDate();

    // Format the DateTime
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
}
