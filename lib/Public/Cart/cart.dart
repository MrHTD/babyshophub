import 'package:babyshophub/Models/cart_model.dart';
import 'package:babyshophub/Public/Cart/cartpricecal.dart';
import 'package:babyshophub/Public/Cart/checkout_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  User? user = FirebaseAuth.instance.currentUser;
  final CartPrice cartPrice = Get.put(CartPrice());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Color.fromRGBO(87, 213, 236, 1)),
        surfaceTintColor: const Color.fromRGBO(241, 244, 248, 1),
        title: const Text(
          "My Cart",
          style: TextStyle(
              color: Color.fromRGBO(87, 213, 236, 1),
              fontWeight: FontWeight.bold),
        ),
        // leading: IconButton(
        //   icon: const Icon(
        //     Icons.arrow_back_ios_new_rounded,
        //     color: Color.fromRGBO(87, 213, 236, 1),
        //   ),
        //   onPressed: () {
        //     Navigator.pop(context); // Navigate back to the previous page
        //   },
        // ),
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
            return ListView.builder(
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
                  productTotalPrice:
                      double.parse(productData['productTotalPrice'].toString()),
                );
                //Calculate Total Price
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
                      onTap: (CompletionHandler handndler) async {
                        print("Deleted");
                        cartPrice.resetTotalPrice();
                        await FirebaseFirestore.instance
                            .collection('Cart')
                            .doc(user!.uid)
                            .collection('CartOrders')
                            .doc(cartModel.productId)
                            .delete();
                      },
                    ),
                  ],
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 0,
                      surfaceTintColor: Colors.white,
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.only(left: 6, right: 10),
                          leading: Image.network(
                            cartModel.imageUrls[0],
                            width: MediaQuery.of(context).size.width * 0.15,
                            height: MediaQuery.of(context).size.height * 0.2,
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
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(87, 213, 236, 1),
                                  fontSize: 15,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Rs. ${cartModel.productTotalPrice}',
                                    style: const TextStyle(
                                      color: Color.fromRGBO(87, 213, 236, 1),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  //+ and -
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_rounded,
                                      color: Color.fromRGBO(87, 213, 236, 1),
                                    ),
                                    onPressed: () async {
                                      if (cartModel.productQuantity > 1) {
                                        await FirebaseFirestore.instance
                                            .collection('Cart')
                                            .doc(user!.uid)
                                            .collection('CartOrders')
                                            .doc(cartModel.productId)
                                            .update({
                                          'productQuantity':
                                              cartModel.productQuantity - 1,
                                          'productTotalPrice': (double.parse(
                                                  cartModel.fullPrice) *
                                              (cartModel.productQuantity - 1))
                                        });
                                      }
                                    },
                                  ),
                                  Text(cartModel.productQuantity.toString()),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_rounded,
                                      color: Color.fromRGBO(87, 213, 236, 1),
                                    ),
                                    onPressed: () async {
                                      if (cartModel.productQuantity > 0) {
                                        await FirebaseFirestore.instance
                                            .collection('Cart')
                                            .doc(user!.uid)
                                            .collection('CartOrders')
                                            .doc(cartModel.productId)
                                            .update({
                                          'productQuantity':
                                              cartModel.productQuantity + 1,
                                          'productTotalPrice': double.parse(
                                                  cartModel.fullPrice) +
                                              double.parse(
                                                      cartModel.fullPrice) *
                                                  (cartModel.productQuantity)
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Container();
        },
      ),
      bottomNavigationBar: Container(
        // margin: const EdgeInsets.only(bottom: 5.0, top: 10),
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
                      elevation: 0,
                    ),
                    child: const Text(
                      "Checkout",
                    ),
                    onPressed: () {
                      if (cartPrice.totalPrice.value == 0.0) {
                        Fluttertoast.showToast(
                          msg: "Add item to Cart First.",
                          toastLength: Toast.LENGTH_SHORT,
                          timeInSecForIosWeb: 1,
                          backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else {
                        cartPrice.resetTotalPrice();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CheckoutScreen(),
                          ),
                        );
                      }
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
}
