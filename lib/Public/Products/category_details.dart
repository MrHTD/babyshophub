import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesDetails extends StatefulWidget {
  final String categoryId;

  const CategoriesDetails({Key? key, required this.categoryId})
      : super(key: key);

  @override
  State<CategoriesDetails> createState() => _CategoriesDetailsState();
}

class _CategoriesDetailsState extends State<CategoriesDetails> {
  Map<String, dynamic>? productData; // Variable to store product data

  Future<void> fetchCategoriesDetails() async {
    print('Fetching product details for document ID: ${widget.categoryId}');
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('Categories')
              .doc(widget.categoryId)
              .get();

      if (snapshot.exists) {
        setState(() {
          productData = snapshot.data();
        });
      } else {
        print('Document does not exist');
      }
    } catch (error) {
      print('Error fetching product details: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    // Call a function to fetch product details when the widget is initialized
    fetchCategoriesDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories Details'),
      ),
      body: Center(
        child: productData != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Product Name: ${productData!['cname']}'),
                  Text('Description: ${productData!['cdescription']}'),
                ],
              )
            : const CircularProgressIndicator(), // Show a loading indicator while fetching data
      ),
    );
  }
}
