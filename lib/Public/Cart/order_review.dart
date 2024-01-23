import 'package:babyshophub/Public/Cart/cartpricecal.dart';
import 'package:babyshophub/Public/address_information.dart';
import 'package:babyshophub/Public/payment_method.dart';
import 'package:babyshophub/Services/place_order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class OrderReview extends StatefulWidget {
  const OrderReview({Key? key}) : super(key: key);

  @override
  State<OrderReview> createState() => _OrderReviewState();
}

class _OrderReviewState extends State<OrderReview> {
  bool useCardPayment = false;
  bool useCodPayment = true;
  User? user = FirebaseAuth.instance.currentUser;
  final CartPrice cartPrice = Get.put(CartPrice());

  Future<String> getCustomerDeviceToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        return token;
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      print("Error $e");
      throw Exception("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Review",
          style: TextStyle(
            color: Color.fromRGBO(87, 213, 236, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: const Color.fromRGBO(87, 213, 236, 1),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        surfaceTintColor: const Color.fromRGBO(241, 244, 248, 1),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(241, 244, 248, 1),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const ListTile(
                title: Text(
                  "Delivery Address",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                elevation: 5,
                surfaceTintColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user!.uid)
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: LinearProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("Error: ${snapshot.error}"),
                        );
                      }
                      if (!snapshot.hasData ||
                          snapshot.data == null ||
                          !snapshot.data!.exists) {
                        return const Center(
                          child: Text("No data found"),
                        );
                      }

                      // Use the existing address information
                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final addressDetails =
                          userData['addressdetail'] as Map<String, dynamic>?;

                      if (addressDetails == null || addressDetails.isEmpty) {
                        return const Center(
                          child: Text("No address details found"),
                        );
                      }

                      final street = addressDetails['street'] as String? ?? '';
                      final city = addressDetails['city'] as String? ?? '';
                      final state = addressDetails['state'] as String? ?? '';
                      final zipcode =
                          addressDetails['zipcode'] as String? ?? '';

                      final contact = userData['phone'] as String? ?? '';

                      final fullAddress = '$street, $city, $state, $zipcode';
                      final Contact = '$contact';

                      return ListTile(
                        title: Text(
                          fullAddress,
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          'Contact No: $Contact',
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AddressInformation(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              const ListTile(
                title: Text(
                  "Payment Methods",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Switch between card and COD
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Pay with Card"),
                    Switch(
                      value: useCardPayment,
                      onChanged: (bool value) {
                        setState(() {
                          useCardPayment = value;
                          useCodPayment =
                              !value; // Disable COD when card payment is selected
                        });
                      },
                    ),
                  ],
                ),
              ),
              // Card details inside StreamBuilder
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(user!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text("No Card Details found");
                  }

                  Map<String, dynamic> userData =
                      snapshot.data!.data() as Map<String, dynamic>;

                  // Check if the user has saved card details
                  if (userData.containsKey('carddetail') && useCardPayment) {
                    Map<String, dynamic> cardDetails = userData['carddetail'];
                    return Visibility(
                      visible:
                          useCardPayment, // Show only if useCardPayment is true
                      child: buildCreditCard(cardDetails),
                    );
                  } else {
                    return Visibility(
                      visible: useCardPayment,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("No Card Details found"),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PaymentMethod(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              // Cash on Delivery
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Cash on Delivery"),
                    Switch(
                      value: useCodPayment,
                      onChanged: (bool value) {
                        setState(() {
                          useCodPayment = value;
                          useCardPayment =
                              !value; // Disable card payment when COD is selected
                        });
                      },
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    String customerToken = await getCustomerDeviceToken();

                    // Fetch the user's data from Firestore
                    DocumentSnapshot userSnapshot = await FirebaseFirestore
                        .instance
                        .collection('Users')
                        .doc(user!.uid)
                        .get();

                    Map<String, dynamic>? addressDetails =
                        userSnapshot['addressdetail'] as Map<String, dynamic>?;

                    // If addressDetails is null, you may want to handle this case
                    final street = addressDetails!['street'] as String? ?? '';
                    final city = addressDetails['city'] as String? ?? '';
                    final state = addressDetails['state'] as String? ?? '';
                    final zipcode = addressDetails['zipcode'] as String? ?? '';

                    final contact = userSnapshot['phone'];
                    final customerName = userSnapshot['name'] as String? ?? '';

                    if (useCardPayment) {
                      // Check if card details are available
                      if (userSnapshot.data() != null &&
                          userSnapshot['carddetail'] != null) {
                        // Fetch card details
                        Map<String, dynamic>? cardDetails =
                            userSnapshot['carddetail'] as Map<String, dynamic>?;

                        if (cardDetails != null) {
                          // ignore: use_build_context_synchronously
                          placeOrder(
                            context: context,
                            customerDeviceToken: customerToken,
                            customerName: customerName,
                            address: street,
                            city: city,
                            state: state,
                            zipcode: zipcode,
                            contact: contact,
                            useCardPayment: useCardPayment,
                            useCodPayment: useCodPayment,
                          );
                          cartPrice.resetTotalPrice();
                        } else {
                          // Display an error message if card details are not available
                          Fluttertoast.showToast(
                            msg:
                                "Please add card details before placing an order.",
                            toastLength: Toast.LENGTH_LONG,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.redAccent,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      } else {
                        // Display an error message if card details are not available
                        Fluttertoast.showToast(
                          msg:
                              "Please add card details before placing an order.",
                          toastLength: Toast.LENGTH_LONG,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.redAccent,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    } else {
                      // For Cash on Delivery (COD)
                      // ignore: use_build_context_synchronously
                      placeOrder(
                        context: context,
                        customerDeviceToken: customerToken,
                        customerName: customerName,
                        address: street,
                        city: city,
                        state: state,
                        zipcode: zipcode,
                        contact: contact,
                        useCardPayment: useCardPayment,
                        useCodPayment: useCodPayment,
                      );
                      cartPrice.resetTotalPrice();
                    }
                  } catch (e) {
                    if (e is FirebaseException &&
                        e.code == 'permission-denied') {
                      // Handle permission-denied error
                      Fluttertoast.showToast(
                        msg:
                            "Permission denied. Please check your Firebase configuration.",
                        toastLength: Toast.LENGTH_LONG,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.redAccent,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else {
                      // Handle other errors
                      if (useCardPayment) {
                        Fluttertoast.showToast(
                          msg:
                              "Please add card details before placing an order.",
                          toastLength: Toast.LENGTH_LONG,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.redAccent,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: "Add Address First.",
                          toastLength: Toast.LENGTH_LONG,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.redAccent,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(87, 213, 236, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Place Order",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Card widget
Widget buildCreditCard(Map<String, dynamic> cardDetails) {
  return GestureDetector(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CreditCardWidget(
          cardNumber: cardDetails['cardnumber'],
          expiryDate: cardDetails['expirydate'],
          cardHolderName: cardDetails['holdername'],
          cvvCode: cardDetails['cvv'],
          showBackView: false,
          cardBgColor: Colors.blueGrey,
          onCreditCardWidgetChange: (CreditCardBrand brand) {},
          obscureCardNumber: false,
          obscureCardCvv: false,
          isHolderNameVisible: true,
          isChipVisible: true,
          isSwipeGestureEnabled: true,
          animationDuration: const Duration(milliseconds: 1000),
        ),
      ],
    ),
  );
}
