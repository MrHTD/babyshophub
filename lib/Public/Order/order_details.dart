import 'package:babyshophub/Models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class OrderDetails extends StatefulWidget {
  final OrderModel orderModel;

  const OrderDetails({Key? key, required this.orderModel}) : super(key: key);

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
      appBar: AppBar(
        surfaceTintColor: const Color.fromRGBO(241, 244, 248, 1),
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
          "Order Details",
          style: TextStyle(
            color: Color.fromRGBO(87, 213, 236, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 20, 2, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 0, 8),
                child: Text(
                  "Order ID: ${widget.orderModel.orderId}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                child: Text(
                    "Date: ${_formatTimestamp(widget.orderModel.createdAt)}"),
              ),
              Card(
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  splashColor: const Color.fromRGBO(87, 213, 236, 0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Ship & Bill to:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(widget.orderModel.customerName),
                                  Text(widget.orderModel.contact),
                                  Text(
                                    '${widget.orderModel.address}, ${widget.orderModel.city}, ${widget.orderModel.state}, ${widget.orderModel.city}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  splashColor: const Color.fromRGBO(87, 213, 236, 0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tracking Number: ${widget.orderModel.orderId}",
                          style: const TextStyle(
                            color: Color.fromRGBO(87, 213, 236, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              child: Image.network(
                                widget.orderModel.imageUrls.isNotEmpty
                                    ? widget.orderModel.imageUrls[0]
                                    : Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.white,
                                        ),
                                      ),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: Text(
                                      widget.orderModel.productName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text("Rs. ${widget.orderModel.fullPrice}"),
                                  Text(
                                    "x ${widget.orderModel.productQuantity}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Spacer(),
                            Text(
                              "Amount: Rs. ${widget.orderModel.productTotalPrice}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(87, 213, 236, 1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Timeline",
                        style: TextStyle(
                          color: Color.fromRGBO(87, 213, 236, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...buildTimelineItems(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildTimelineItems() {
    List<Widget> timelineItems = [];

    if (widget.orderModel.createdAt != null) {
      timelineItems.add(
        Card(
          color: const Color.fromRGBO(241, 244, 248, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          child: Column(
            children: [
              buildTimelineItem(
                "Order Placed",
                widget.orderModel.createdAt,
                Icons.timeline,
              ),
            ],
          ),
        ),
      );
    }

    if (widget.orderModel.confirmedAt != null &&
        (widget.orderModel.status == 'Confirmed' ||
            widget.orderModel.status == 'Shipped' ||
            widget.orderModel.status == 'Delivered')) {
      timelineItems.add(
        Card(
          color: const Color.fromRGBO(241, 244, 248, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          child: Column(
            children: [
              buildTimelineItem(
                "Order Confirmed",
                widget.orderModel.confirmedAt,
                Icons.check_circle_outline_rounded,
              ),
            ],
          ),
        ),
      );
    }

    if (widget.orderModel.shippedAt != null &&
        (widget.orderModel.status == 'Shipped' ||
            widget.orderModel.status == 'Delivered')) {
      timelineItems.add(
        Card(
          color: const Color.fromRGBO(241, 244, 248, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          child: Column(
            children: [
              buildTimelineItem(
                "Order Shipped",
                widget.orderModel.shippedAt,
                Icons.local_shipping_rounded,
              ),
            ],
          ),
        ),
      );
    }

    if (widget.orderModel.deliveredAt != null &&
        widget.orderModel.status == 'Delivered') {
      timelineItems.add(
        Card(
          color: const Color.fromRGBO(241, 244, 248, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          child: Column(
            children: [
              buildTimelineItem(
                "Order Delivered",
                widget.orderModel.deliveredAt,
                Icons.delivery_dining_rounded,
              ),
            ],
          ),
        ),
      );
    }
    if (widget.orderModel.cancelledAt != null &&
        widget.orderModel.status == 'Cancelled') {
      timelineItems.add(
        Card(
          color: const Color.fromRGBO(241, 244, 248, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          child: Column(
            children: [
              buildTimelineItem(
                "Order Cancelled",
                widget.orderModel.cancelledAt,
                Icons.delivery_dining_rounded,
              ),
            ],
          ),
        ),
      );
    }

    return timelineItems;
  }

  Widget buildTimelineItem(String title, Timestamp timestamp, IconData icon) {
    return ListTile(
      title: Text(title),
      subtitle: Text(_formatTimestamp(timestamp)),
      leading: Icon(
        icon,
        color: const Color.fromRGBO(87, 213, 236, 1),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
  }
}
