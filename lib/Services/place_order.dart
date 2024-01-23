import 'dart:math';
import 'package:babyshophub/Models/order_model.dart';
import 'package:babyshophub/Public/navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

String generateOrderId() {
  DateTime now = DateTime.now();

  // int randomNumbers = Random().nextInt(99999);
  String id = '${now.microsecondsSinceEpoch}';

  return id;
}

String generateTrackingId() {
  // DateTime now = DateTime.now();
  String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  String tId =
      List.generate(10, (index) => alphabet[Random().nextInt(alphabet.length)])
          .join('');

  // String trackingId = randomLetters;

  return tId;
}

Future<void> placeOrder({
  required BuildContext context,
  required String customerName,
  required String address,
  required String city,
  required String state,
  required String zipcode,
  required String contact,
  required String customerDeviceToken,
  required bool useCardPayment,
  required bool useCodPayment,
}) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      // Check if the cart is not empty
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('Cart')
          .doc(user.uid)
          .collection('CartOrders')
          .get();

      if (cartSnapshot.docs.isEmpty) {
        Fluttertoast.showToast(
          msg: "Cart is empty. Add items to the cart first.",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }

      // Check if either useCardPayment or useCodPayment is true
      if (!useCardPayment && !useCodPayment) {
        Fluttertoast.showToast(
          msg: "Select a payment method (Card or Cash on Delivery).",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }

      // Generate a single order ID
      String orderId = generateOrderId();
      String trackingId = generateTrackingId();

      // Use a Firestore transaction for multiple operations
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Update user's orders with order details
        transaction.set(
          FirebaseFirestore.instance.collection('Orders').doc(user.uid),
          {
            'uId': user.uid,
            'customerName': customerName,
            'address': address,
            'city': city,
            'state': state,
            'zipcode': zipcode,
            'contact': contact,
            'customerDeviceToken': customerDeviceToken,
            'createdAt': DateTime.now(),
            'useCardPayment': useCardPayment,
            'useCodPayment': useCodPayment,
          },
        );

        // Process each cart item
        cartSnapshot.docs.forEach((cartItem) async {
          Map<String, dynamic>? data = cartItem.data() as Map<String, dynamic>;

          OrderModel cartModel = OrderModel(
            productId: data['productId'] ?? '',
            productName: data['productName'] ?? '',
            fullPrice: data['fullPrice'] ?? 0.0,
            imageUrls: (data['imageUrls'] as List<dynamic>?) ?? [],
            deliveryTime: data['deliveryTime'] ?? '',
            productDescription: data['productDescription'] ?? '',
            createdAt: data['createdAt'] ?? DateTime.now(),
            confirmedAt: data['confirmedAt'] ?? DateTime.now(),
            shippedAt: data['shippedAt'] ?? DateTime.now(),
            deliveredAt: data['deliveredAt'] ?? DateTime.now(),
            cancelledAt: data['cancelledAt'] ?? DateTime.now(),
            updatedAt: data['updatedAt'] ?? DateTime.now(),
            productQuantity: data['productQuantity'] ?? 0,
            productTotalPrice: data['productTotalPrice']?.toDouble() ?? 0.0,
            customerId: user.uid,
            customerName: customerName,
            status: "Pending",
            address: address,
            city: city,
            state: state,
            zipcode: zipcode,
            contact: contact,
            customerDeviceToken: customerDeviceToken,
            orderId: orderId,
            trackingId: trackingId,
            useCardPayment: useCardPayment,
            useCodPayment: useCodPayment,
          );

          // Upload orders to ConfirmOrders
          transaction.set(
            FirebaseFirestore.instance
                .collection('Orders')
                .doc(user.uid)
                .collection('ConfirmOrders')
                .doc(orderId + data['productId']),
            cartModel.toMap(),
          );

          // Delete cart products
          transaction.delete(cartItem.reference);
        });
      });

      Fluttertoast.showToast(
        msg: "Order Confirmed",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } catch (e) {
      print("Error placing order: $e");
      Fluttertoast.showToast(
        msg: "Error placing order. Please try again.",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}



        // OrderModel cartModel = OrderModel(
        //   productId: data['productId'] ?? '',
        //   productName: data['productName'] ?? '',
        //   fullPrice: data['fullPrice'] ?? 0.0,
        //   imageUrls: (data['imageUrls'] as List<dynamic>?) ?? [],
        //   deliveryTime: data['deliveryTime'] ?? '',
        //   productDescription: data['productDescription'] ?? '',
        //   createdAt: data['createdAt'] ?? DateTime.now(),
        //   updatedAt: data['updatedAt'] ?? DateTime.now(),
        //   productQuantity: data['productQuantity'] ?? 0,
        //   productTotalPrice: data['productTotalPrice']?.toDouble() ?? 0.0,
        //   customerId: user.uid,
        //   customerName: customerName,
        //   status: "Pending",
        //   address: address,
        //   city: city,
        //   state: state,
        //   zipcode: zipcode,
        //   contact: contact,
        //   customerDeviceToken: customerDeviceToken,
        //   orderId: orderId,
        // );