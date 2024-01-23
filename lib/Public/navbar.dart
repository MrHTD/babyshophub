import 'dart:async';

import 'package:babyshophub/Public/Cart/cart.dart';
import 'package:babyshophub/Public/search.dart';
import 'package:babyshophub/main_screen.dart';
import 'package:babyshophub/profile.dart';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:badges/badges.dart' as badges;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? user = FirebaseAuth.instance.currentUser;

  int _selectedIndex = 0;
  int cartItemCount = 0;

  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      _cartSubscription;

  Future<void> updateCartItemCount() async {
    int count = await getCartItemCount();
    setState(() {
      cartItemCount = count;
    });
  }

  Future<int> getCartItemCount() async {
    // Fetch the cart item count
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Cart')
        .doc(user!.uid)
        .collection('CartOrders')
        .get();

    int itemCount = snapshot.size;
    return itemCount;
  }

  @override
  void initState() {
    super.initState();
    updateCartItemCount();

    // Subscribe to changes in the cart collection
    _cartSubscription = FirebaseFirestore.instance
        .collection('Cart')
        .doc(user!.uid)
        .collection('CartOrders')
        .snapshots()
        .listen((snapshot) {
      updateCartItemCount();
    });
  }

  @override
  void dispose() {
    // Cancel the stream subscription when the widget is disposed
    _cartSubscription.cancel();
    super.dispose();
  }

  Future<String> getEmail() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var obtemail = sharedPreferences.getString("email");
    return obtemail ?? "";
  }

  Future<String> getRole() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var role = sharedPreferences.getString("role");
    return role ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
      body: Center(
        child: _selectedIndex >= 0 && _selectedIndex < _widgetOptions.length
            ? _widgetOptions[_selectedIndex]
            : const Text('Invalid Index'),
      ),
      bottomNavigationBar: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.09,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: GNav(
            rippleColor: Colors.white24,
            hoverColor: Colors.white70,
            gap: 8,
            haptic: true,
            tabBorderRadius: 30,
            backgroundColor: const Color.fromRGBO(253, 253, 253, 1),
            color: const Color.fromRGBO(193, 200, 212, 1),
            activeColor: const Color.fromRGBO(87, 213, 236, 1),
            iconSize: 30,
            tabs: [
              const GButton(
                icon: Icons.home_filled,
                text: 'Home',
                haptic: true,
                margin: EdgeInsets.only(left: 5),
              ),
              const GButton(
                icon: Icons.search_rounded,
                text: 'Search',
                haptic: true,
              ),
              GButton(
                icon: Icons.shopping_cart_rounded,
                text: 'Cart',
                haptic: true,
                leading: badges.Badge(
                  badgeStyle: const badges.BadgeStyle(
                    badgeColor: Colors.pink,
                    elevation: 0,
                  ),
                  position: BadgePosition.topEnd(top: -20, end: -10),
                  badgeContent:
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('Cart')
                        .doc(user!.uid)
                        .collection('CartOrders')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 10,
                          height: null,
                          child: CircularProgressIndicator(
                            value: null,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.transparent),
                            backgroundColor: Colors.transparent,
                            strokeWidth: 1.0,
                            semanticsLabel: 'Loading',
                            semanticsValue: null,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Text('Error loading cart');
                      } else {
                        int itemCount = snapshot.data!.size;
                        return Text(
                          itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        );
                      }
                    },
                  ),
                  child: Icon(
                    Icons.shopping_cart_rounded,
                    color: _selectedIndex == 2
                        ? const Color.fromRGBO(87, 213, 236, 1)
                        : Colors.grey,
                  ),
                ),
              ),
              const GButton(
                icon: Icons.person_rounded,
                text: 'Profile',
                margin: EdgeInsets.only(right: 5),
                haptic: true,
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(
                () {
                  _selectedIndex = index;
                },
              );
              updateCartItemCount();
            },
          ),
        ),
      ),
    );
  }

  static const List<Widget> _widgetOptions = <Widget>[
    MainScreen(),
    Search(),
    Cart(),
    Profile(),
  ];
}
