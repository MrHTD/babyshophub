// import 'package:babyshophub/Public/Cart/cart.dart';
import 'package:babyshophub/Public/Products/all_products.dart';
import 'package:babyshophub/Public/Products/products.dart';
import 'package:babyshophub/Public/search.dart';
import 'package:babyshophub/Widget/brand_widget.dart';
import 'package:babyshophub/Widget/category_widget.dart';
import 'package:babyshophub/Widget/heading_widget.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Widget/banner_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
          leadingWidth: MediaQuery.of(context).size.width * 0.85,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8, right: 4),
                    child: Icon(
                      Icons.search,
                      color: Color.fromRGBO(193, 200, 212, 1),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: TextField(
                        style: const TextStyle(color: Colors.grey),
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(193, 200, 212, 1),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        focusNode: FocusScopeNode(skipTraversal: false),
                        showCursor: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Search(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          surfaceTintColor: const Color.fromRGBO(241, 244, 248, 1),
          actions: <Widget>[
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.white,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications_rounded,
                          color: Color.fromRGBO(87, 213, 236, 1),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const BannerWidget(),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Text(
                      'Brands',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              const Brands(),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              const Categories(),
              HeadingWidget(
                headingtitle: 'Products',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AllProducts()),
                  );
                },
                buttontext: 'See More',
              ),
              const Products(),
            ],
          ),
        ),
      ),
    );
  }
}
