import 'package:babyshophub/Feedback/support.dart';
import 'package:babyshophub/Public/Order/orders.dart';
import 'package:babyshophub/Public/Reviews/my_reviews.dart';
import 'package:babyshophub/Public/address_information.dart';
import 'package:babyshophub/Public/forget_password.dart';
import 'package:babyshophub/Public/login.dart';
import 'package:babyshophub/Public/payment_method.dart';
import 'package:babyshophub/Public/profile_settings.dart';
import 'package:babyshophub/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;

Stream<String> getImageUrlStream(String userUid) {
  try {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .snapshots()
        .map((userDoc) {
      if (userDoc.exists) {
        // Assuming the image URL is stored in a field named 'imageUrl', adjust accordingly
        return userDoc['imageUrl'].toString();
      } else {
        // Handle the case where the document (user) is not found in the database
        return 'No Image Found';
      }
    });
  } catch (e) {
    print('Error getting Image: $e');
    return Stream.value(
        ''); // Return an empty string or some default value when an error occurs
  }
}

Stream<String> getUserNameStream(String userUid) {
  try {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .snapshots()
        .map((userDoc) {
      if (userDoc.exists) {
        // Assuming the name is stored in a field named 'name', adjust accordingly
        return userDoc['name'].toString();
      } else {
        // Handle the case where the document (user) is not found in the database
        return 'No Name Found';
      }
    });
  } catch (e) {
    print('Error getting name: $e');
    return Stream.value('');
  }
}

class _ProfileState extends State<Profile> {
  static void logout(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();

    var sharedpref = await SharedPreferences.getInstance();
    sharedpref.setBool(SplashPageState.KEYLOGIN, false);

    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
    print(Navigator.of(context).toString());
    Fluttertoast.showToast(
      msg: "User Logout.",
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: const Color.fromRGBO(241, 244, 248, 1),
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Color.fromRGBO(87, 213, 236, 1),
              fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Color.fromRGBO(87, 213, 236, 1),
                ),
                foregroundColor: MaterialStatePropertyAll(Colors.white),
              ),
              onPressed: () {
                logout(context);
              },
              child: const Text("Logout"),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                shadowColor: Colors.white,
                elevation: 0,
                surfaceTintColor: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  splashColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Setting()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: Material(
                            shape: const CircleBorder(),
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: Center(
                                child: _auth.currentUser != null
                                    ? StreamBuilder<String>(
                                        stream: getImageUrlStream(
                                            _auth.currentUser!.uid),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              direction: ShimmerDirection.ttb,
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              direction: ShimmerDirection.ttb,
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          } else if (snapshot.data != null &&
                                              snapshot.data!.isNotEmpty) {
                                            // Display the image using Image.network
                                            return ClipOval(
                                              child: Image.network(
                                                snapshot.data!,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          } else {
                                            return Image.asset(
                                                'assets/images/user.png');
                                          }
                                        },
                                      )
                                    : Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        direction: ShimmerDirection.ttb,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          alignment: Alignment.center,
                          child: StreamBuilder<String>(
                            stream: getUserNameStream(_auth.currentUser!.uid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                String name = snapshot.data ?? 'No Name';
                                return Container(
                                  padding: const EdgeInsets.all(10.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      color: Color.fromRGBO(87, 213, 236, 1),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.fade,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color.fromRGBO(87, 213, 236, 1),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              shadowColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                splashColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Orders(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(87, 213, 236, 1),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: const Icon(
                          Icons.inventory_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "My Orders",
                          style: TextStyle(
                            color: Color.fromRGBO(87, 213, 236, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color.fromRGBO(87, 213, 236, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              shadowColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                splashColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddressInformation(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(87, 213, 236, 1),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Expanded(
                        child: Text(
                          "Shipping Address",
                          style: TextStyle(
                            color: Color.fromRGBO(87, 213, 236, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color.fromRGBO(87, 213, 236, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              shadowColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                splashColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentMethod(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(87, 213, 236, 1),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: const Icon(
                          Icons.attach_money_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Payment Methods",
                          style: TextStyle(
                            color: Color.fromRGBO(87, 213, 236, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color.fromRGBO(87, 213, 236, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              shadowColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                splashColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyReviews(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(87, 213, 236, 1),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: const Icon(
                          Icons.rate_review_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "My Reviews",
                          style: TextStyle(
                            color: Color.fromRGBO(87, 213, 236, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color.fromRGBO(87, 213, 236, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              shadowColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                splashColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Support(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(87, 213, 236, 1),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: const Icon(
                          Icons.feedback_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Feedback and Support",
                          style: TextStyle(
                            color: Color.fromRGBO(87, 213, 236, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color.fromRGBO(87, 213, 236, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              shadowColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                splashColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgetPassword(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(87, 213, 236, 1),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: const Icon(
                          Icons.password_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Forget Password",
                          style: TextStyle(
                            color: Color.fromRGBO(87, 213, 236, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color.fromRGBO(87, 213, 236, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
