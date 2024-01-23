import 'package:babyshophub/Models/cart_model.dart';
import 'package:babyshophub/Public/Cart/cartpricecal.dart';
import 'package:babyshophub/Public/Cart/order_review.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get/get.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  final CartPrice cartPrice = Get.put(CartPrice());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
      appBar: AppBar(
        surfaceTintColor: const Color.fromRGBO(241, 244, 248, 1),
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
          "Checkout Screen",
          style: TextStyle(
            color: Color.fromRGBO(87, 213, 236, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Cart')
            .doc(user!.uid)
            .collection('CartOrders')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }

          if (snapshot.data != null) {
            return Container(
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final productData = snapshot.data!.docs[index];
                  CartModel cartModel = CartModel(
                    productId: productData['productId'],
                    productName: productData['productName'],
                    fullPrice: productData['fullPrice'],
                    imageUrls: productData['imageUrls'],
                    productDescription: productData['productDescription'],
                    createdAt: productData['createdAt'],
                    updatedAt: productData['updatedAt'],
                    productQuantity: productData['productQuantity'],
                    productTotalPrice: double.parse(
                        productData['productTotalPrice'].toString()),
                  );
                  // Calculate Total Price
                  cartPrice.fetchProductPrice();
                  return SwipeActionCell(
                    backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
                    key: ObjectKey(cartModel.productId),
                    trailingActions: [
                      SwipeAction(
                        title: "Delete",
                        color: Colors.redAccent,
                        forceAlignmentToBoundary: true,
                        performsFirstActionWithFullSwipe: true,
                        onTap: (CompletionHandler handler) async {
                          print("Deleted");

                          await FirebaseFirestore.instance
                              .collection('Cart')
                              .doc(user!.uid)
                              .collection('CartOrders')
                              .doc(cartModel.productId)
                              .delete();
                        },
                      )
                    ],
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        elevation: 5,
                        surfaceTintColor: Colors.white,
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ListTile(
                            leading: Image.network(
                              cartModel.imageUrls[0],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cartModel.productName,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(87, 213, 236, 1),
                                  ),
                                ),
                                Text(
                                  'Rs. ${cartModel.productTotalPrice}',
                                  style: const TextStyle(
                                    color: Color.fromRGBO(87, 213, 236, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return Container();
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(5),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          surfaceTintColor: Colors.white,
          elevation: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(
                () => Text(
                  " Total : ${cartPrice.totalPrice.value.toStringAsFixed(1)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromRGBO(87, 213, 236, 1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(87, 213, 236, 1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Confirm Order",
                    ),
                    onPressed: () {
                      // showCustomScreen(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OrderReview()),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void showCustomScreen(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext buildContext) {
  //       return Container(
  //         height: MediaQuery.of(context).size.height,
  //         decoration: const BoxDecoration(
  //           color: Color.fromRGBO(241, 244, 248, 1),
  //           borderRadius: BorderRadius.vertical(
  //             top: Radius.circular(20),
  //           ),
  //         ),
  //         child: SingleChildScrollView(
  //           child: Column(
  //             children: [
  //               const ListTile(
  //                 title: Text(
  //                   "Delivery Address",
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ),
  //               Card(
  //                 elevation: 5,
  //                 surfaceTintColor: Colors.white,
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(10.0),
  //                   child: FutureBuilder<DocumentSnapshot>(
  //                     future: FirebaseFirestore.instance
  //                         .collection('Users')
  //                         .doc(user!.uid)
  //                         .get(),
  //                     builder: (BuildContext context,
  //                         AsyncSnapshot<DocumentSnapshot> snapshot) {
  //                       if (snapshot.connectionState ==
  //                           ConnectionState.waiting) {
  //                         return const Center(
  //                             child: CircularProgressIndicator());
  //                       }
  //                       if (snapshot.hasError) {
  //                         return Center(
  //                           child: Text("Error: ${snapshot.error}"),
  //                         );
  //                       }
  //                       if (!snapshot.hasData ||
  //                           snapshot.data == null ||
  //                           !snapshot.data!.exists) {
  //                         return const Center(
  //                           child: Text("No data found"),
  //                         );
  //                       }

  //                       // Use the existing address information
  //                       final userData =
  //                           snapshot.data!.data() as Map<String, dynamic>;
  //                       final addressDetails =
  //                           userData['addressdetail'] as Map<String, dynamic>?;

  //                       if (addressDetails == null || addressDetails.isEmpty) {
  //                         return const Center(
  //                           child: Text("No address details found"),
  //                         );
  //                       }

  //                       final street =
  //                           addressDetails['street'] as String? ?? '';
  //                       final city = addressDetails['city'] as String? ?? '';
  //                       final state = addressDetails['state'] as String? ?? '';
  //                       final zipcode =
  //                           addressDetails['zipcode'] as String? ?? '';

  //                       final contact = userData['phone'] as String? ?? '';

  //                       final fullAddress = '$street, $city, $state, $zipcode';
  //                       final Contact = '$contact';

  //                       return ListTile(
  //                         title: Text(
  //                           fullAddress,
  //                           style: const TextStyle(fontSize: 16),
  //                         ),
  //                         subtitle: Text(
  //                           'Contact No: $Contact',
  //                           style: const TextStyle(fontSize: 16),
  //                         ),
  //                         trailing: IconButton(
  //                           icon: const Icon(Icons.edit),
  //                           onPressed: () {
  //                             Navigator.push(
  //                               context,
  //                               MaterialPageRoute(
  //                                 builder: (context) =>
  //                                     const AddressInformation(),
  //                               ),
  //                             );
  //                           },
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ),
  //               const ListTile(
  //                 title: Text(
  //                   "Payment Methods",
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   try {
  //                     String customerToken = await getCustomerDeviceToken();

  //                     // Fetch the user's data from Firestore
  //                     DocumentSnapshot userSnapshot = await FirebaseFirestore
  //                         .instance
  //                         .collection('Users')
  //                         .doc(user!.uid)
  //                         .get();

  //                     Map<String, dynamic>? addressDetails =
  //                         userSnapshot['addressdetail']
  //                             as Map<String, dynamic>?;

  //                     // If addressDetails is null, you may want to handle this case
  //                     final street = addressDetails!['street'] as String? ?? '';
  //                     final city = addressDetails['city'] as String? ?? '';
  //                     final state = addressDetails['state'] as String? ?? '';
  //                     final zipcode =
  //                         addressDetails['zipcode'] as String? ?? '';

  //                     final contact = userSnapshot['phone'];
  //                     final customerName =
  //                         userSnapshot['name'] as String? ?? '';

  //                     // ignore: use_build_context_synchronously
  //                     placeOrder(
  //                       context: context,
  //                       customerDeviceToken: customerToken,
  //                       customerName: customerName,
  //                       address: street,
  //                       city: city,
  //                       state: state,
  //                       zipcode: zipcode,
  //                       contact: contact,
  //                     );
  //                     cartPrice.resetTotalPrice();
  //                   } catch (e) {
  //                     Fluttertoast.showToast(
  //                       msg: "Add Address First.",
  //                       toastLength: Toast.LENGTH_LONG,
  //                       timeInSecForIosWeb: 1,
  //                       backgroundColor: Colors.redAccent,
  //                       textColor: Colors.white,
  //                       fontSize: 16.0,
  //                     );
  //                   }
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: const Color.fromRGBO(87, 213, 236, 1),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(20),
  //                   ),
  //                 ),
  //                 child: const Text(
  //                   "Place Order",
  //                   style: TextStyle(color: Colors.white),
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
