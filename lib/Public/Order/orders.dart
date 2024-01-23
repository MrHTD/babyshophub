import 'package:babyshophub/Public/Order/order_card.dart';
import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
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
            "My Orders",
            style: TextStyle(
              color: Color.fromRGBO(87, 213, 236, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: flipAxis(
                axisDirectionToAxis(AxisDirection.right),
              ),
              reverse: true,
              child: TabBar(
                isScrollable: true,
                tabs: const [
                  Tab(
                    child: Text(
                      'All',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Pending',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Shipped',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Delivered',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Cancelled',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
                padding: const EdgeInsets.all(10),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color.fromRGBO(87, 213, 236, 1),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: const Color.fromRGBO(87, 213, 236, 1),
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SingleChildScrollView(
                    child: OrderCard(status: ''),
                  ),
                  SingleChildScrollView(
                    child: OrderCard(status: 'Pending'),
                  ),
                  // SingleChildScrollView(
                  //   child: OrderCard(status: 'Confirmed'),
                  // ),
                  SingleChildScrollView(
                    child: OrderCard(status: 'Shipped'),
                  ),
                  SingleChildScrollView(
                    child: OrderCard(status: 'Delivered'),
                  ),
                  SingleChildScrollView(
                    child: OrderCard(status: 'Cancelled'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
