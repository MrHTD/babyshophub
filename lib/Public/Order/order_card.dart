import 'package:babyshophub/Models/order_model.dart';
import 'package:babyshophub/Public/Order/order_details.dart';
import 'package:babyshophub/Public/Reviews/product_review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class OrderCard extends StatelessWidget {
  final String status;

  OrderCard({Key? key, required this.status}) : super(key: key);

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(241, 244, 248, 1),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .doc(user!.uid)
            .collection('ConfirmOrders')
            .orderBy('createdAt', descending: true)
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
      List<OrderModel> rowProducts = [];
      for (int j = i; j < i + productsPerRow && j < products.length; j++) {
        QueryDocumentSnapshot productData = products[j];
        OrderModel orderModel;

        // Add this conditional check to filter orders by status
        if (status.isEmpty || productData['status'] == status) {
          orderModel = OrderModel(
            productId: productData['productId'] ?? '',
            productName: productData['productName'] ?? '',
            fullPrice: productData['fullPrice'] ?? '',
            imageUrls: productData['imageUrls'] ?? '',
            deliveryTime: productData['deliveryTime'] ?? '',
            productDescription: productData['productDescription'] ?? '',
            createdAt: productData['createdAt'] ?? '',
            confirmedAt: productData['confirmedAt'] ?? '',
            shippedAt: productData['shippedAt'] ?? '',
            deliveredAt: productData['deliveredAt'] ?? '',
            cancelledAt: productData['cancelledAt'] ?? '',
            updatedAt: productData['updatedAt'] ?? '',
            productQuantity: productData['productQuantity'] ?? '',
            productTotalPrice: productData['productTotalPrice'] ?? '',
            customerId: productData['customerId'] ?? '',
            customerName: productData['customerName'] ?? '',
            status: productData['status'] ?? '',
            address: productData['address'] ?? '',
            city: productData['city'] ?? '',
            state: productData['state'] ?? '',
            zipcode: productData['zipcode'] ?? '',
            contact: productData['contact'] ?? '',
            orderId: productData['orderId'],
            trackingId: productData['trackingId'],
            customerDeviceToken: productData['customerDeviceToken'] ?? '',
            useCardPayment: productData['useCardPayment'] ?? '',
            useCodPayment: productData['useCodPayment'] ?? '',
          );

          if (orderModel.productId.isNotEmpty &&
              orderModel.productName.isNotEmpty &&
              orderModel.fullPrice.isNotEmpty &&
              orderModel.imageUrls.isNotEmpty) {
            rowProducts.add(orderModel);
          }
        }
      }

      if (rowProducts.isNotEmpty) {
        rows.add(_buildProductRow(context, rowProducts));
      }
    }

    return rows;
  }

  Widget _buildProductRow(BuildContext context, List<OrderModel> products) {
    return Column(
      children: products
          .map((product) => _buildProductCard(context, product))
          .toList(),
    );
  }

  Widget _buildProductCard(BuildContext context, OrderModel orderModel) {
    bool isCompleted = orderModel.status == 'Delivered';

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Card(
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white,
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Order ID: ${orderModel.orderId}",
                      style: const TextStyle(
                        color: Color.fromRGBO(87, 213, 236, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  "Date & Time: ${_formatTimestamp(orderModel)}",
                  maxLines: 2,
                  style: const TextStyle(
                    color: Color.fromRGBO(87, 213, 236, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Tracking Number: ${orderModel.trackingId}",
                  style: const TextStyle(
                    // color: Color.fromRGBO(87, 213, 236, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Adjust font size as needed
                  ),
                ),
                Text(
                  "${orderModel.useCodPayment ? 'Pay on: COD' : ''}${orderModel.useCardPayment ? '${orderModel.useCodPayment ? ' || ' : ''}Paid With: Card' : ''}",
                  style: const TextStyle(
                    // color: Color.fromRGBO(87, 213, 236, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Adjust font size as needed
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      child: orderModel.imageUrls.isNotEmpty
                          ? Image.network(
                              orderModel.imageUrls[0],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    color:
                                        Colors.white, // or any color you want
                                  ),
                                );
                              },
                              loadingBuilder: (BuildContext context,
                                  Widget child,
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
                              child: Container(
                                width: 80,
                                height: 80,
                                color: Colors.white,
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
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Text(
                              orderModel.productName,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "x ${orderModel.productQuantity}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Rs: ${orderModel.productTotalPrice}"),
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
                          side: MaterialStateProperty.resolveWith((states) {
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
                              builder: (context) =>
                                  OrderDetails(orderModel: orderModel),
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
                    Container(
                      decoration: BoxDecoration(
                        color: getRatingbgColor(orderModel.status),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          orderModel.status,
                          style: TextStyle(
                            color: getRatingColor(orderModel.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isCompleted)
                  Center(
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                          Color.fromRGBO(87, 213, 236, 1),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductReview(orderModel: orderModel),
                          ),
                        );
                      },
                      child: const Text(
                        "Review",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color getRatingbgColor(String status) {
    if (status == "Delivered") {
      return Colors.green.shade50;
    } else if (status == "Shipped") {
      return Colors.blueGrey.shade50;
    } else if (status == "Confirmed") {
      return Colors.lightBlue.shade50;
    } else if (status == "Pending") {
      return Colors.orange.shade50;
    } else {
      return Colors.red.shade50;
    }
  }

  Color getRatingColor(String status) {
    if (status == "Delivered") {
      return Colors.green.shade300;
    } else if (status == "Shipped") {
      return Colors.blueGrey.shade300;
    } else if (status == "Confirmed") {
      return Colors.lightBlue.shade300;
    } else if (status == "Pending") {
      return Colors.orange.shade300;
    } else {
      return Colors.red.shade300;
    }
  }

  String _formatTimestamp(OrderModel orderModel) {
    DateTime dateTime;

    // Choose the appropriate timestamp based on the order status
    switch (orderModel.status) {
      case 'Confirmed':
        dateTime = orderModel.confirmedAt.toDate();
        break;
      case 'Shipped':
        dateTime = orderModel.shippedAt.toDate();
        break;
      case 'Delivered':
        dateTime = orderModel.deliveredAt.toDate();
        break;
      // Add more cases for other statuses if needed
      default:
        // For 'Pending' or other statuses, use the 'createdAt' timestamp
        dateTime = orderModel.createdAt.toDate();
    }

    // Format the DateTime
    return DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
  }
}
