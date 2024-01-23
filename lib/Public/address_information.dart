import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddressInformation extends StatefulWidget {
  const AddressInformation({Key? key}) : super(key: key);

  @override
  State<AddressInformation> createState() => _AddressInformationState();
}

class _AddressInformationState extends State<AddressInformation> {
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          "My Address",
          style: TextStyle(
            color: Color.fromRGBO(87, 213, 236, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Add your edit button here
          IconButton(
            icon: const Icon(
              Icons.add_rounded,
              color: Color.fromRGBO(87, 213, 236, 1),
            ),
            onPressed: () {
              _showAddAddressModal(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Show existing addresses
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(user!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text("No address found");
              }

              Map<String, dynamic> userData =
                  snapshot.data!.data() as Map<String, dynamic>;

              // Check if the user has address details
              if (userData.containsKey('addressdetail')) {
                Map<String, dynamic> addressDetails = userData['addressdetail'];
                return buildAddressCard(addressDetails);
              } else {
                return const Center(
                  child: Text("No address found"),
                );
              }
            },
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _showAddAddressModal(context);
      //   },
      //   backgroundColor: const Color.fromRGBO(87, 213, 236, 1),
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildAddressCard(Map<String, dynamic> addressDetails) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          _showAddAddressModal(context);
        },
        child: Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: Colors.white, width: 3.0),
          ),
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 10, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(user!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Text("No user data found");
                    }

                    Map<String, dynamic> userData =
                        snapshot.data!.data() as Map<String, dynamic>;

                    // Check if the user has a name
                    if (userData.containsKey('name')) {
                      String userName = userData['name'];

                      // Display the user's name
                      return Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else {
                      return const Text("No name found in user data");
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Address: ${addressDetails['street'] + ', ' + addressDetails['city'] + ', ' + addressDetails['state'] + ', ' + addressDetails['zipcode']}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 20),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(user!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Text("No phone data found");
                    }

                    Map<String, dynamic> userData =
                        snapshot.data!.data() as Map<String, dynamic>;

                    // Check if the user has a name
                    if (userData.containsKey('phone')) {
                      String phone = userData['phone'];

                      // Display the user's name
                      return Text(
                        phone,
                      );
                    } else {
                      return const Text("No name found in phone data");
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddAddressModal(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // Dismiss the keyboard when tapping outside the text fields
            FocusScope.of(context).unfocus();
          },
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(user!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text("No user data found");
              }

              Map<String, dynamic> userData =
                  snapshot.data!.data() as Map<String, dynamic>;

              String name =
                  userData.containsKey('name') ? userData['name'] ?? '' : '';
              String phone =
                  userData.containsKey('phone') ? userData['phone'] ?? '' : '';
              // Extract existing address details
              String existingStreet = userData.containsKey('addressdetail')
                  ? userData['addressdetail']['street'] ?? ''
                  : '';
              String existingCity = userData.containsKey('addressdetail')
                  ? userData['addressdetail']['city'] ?? ''
                  : '';
              String existingState = userData.containsKey('addressdetail')
                  ? userData['addressdetail']['state'] ?? ''
                  : '';
              String existingZipcode = userData.containsKey('addressdetail')
                  ? userData['addressdetail']['zipcode'] ?? ''
                  : '';

              // Set existing values to text controllers
              addressController.text = existingStreet;
              cityController.text = existingCity;
              stateController.text = existingState;
              zipcodeController.text = existingZipcode;
              nameController.text = name;
              phoneController.text = phone;

              return ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Edit Address',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                              labelText: 'Name', hintText: 'Enter Name'),
                          keyboardType: TextInputType.name,
                          controller: nameController,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              labelText: 'Phone', hintText: 'Enter Phone'),
                          keyboardType: TextInputType.text,
                          controller: phoneController,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              labelText: 'Street', hintText: 'Enter street'),
                          keyboardType: TextInputType.streetAddress,
                          controller: addressController,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              labelText: 'City', hintText: 'Enter city'),
                          controller: cityController,
                          keyboardType: TextInputType.text,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              labelText: 'State', hintText: 'Enter state'),
                          keyboardType: TextInputType.text,
                          controller: stateController,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              labelText: 'Zip Code',
                              hintText: 'Enter zip code'),
                          keyboardType: TextInputType.number,
                          controller: zipcodeController,
                        ),
                        const SizedBox(height: 50),
                        ElevatedButton(
                          onPressed: () async {
                            if (addressController.text.isNotEmpty &&
                                cityController.text.isNotEmpty &&
                                stateController.text.isNotEmpty &&
                                zipcodeController.text.isNotEmpty &&
                                nameController.text.isNotEmpty &&
                                phoneController.text.isNotEmpty) {
                              String address = addressController.text.trim();
                              String city = cityController.text.trim();
                              String state = stateController.text.trim();
                              String zipcode = zipcodeController.text.trim();
                              String name = nameController.text.trim();
                              String phone = phoneController.text.trim();

                              String userId = user!.uid;

                              // Reference to the users collection in Firestore
                              CollectionReference users = FirebaseFirestore
                                  .instance
                                  .collection('Users');

                              // Construct the address details
                              Map<String, dynamic> addressDetails = {
                                'street': address,
                                'city': city,
                                'state': state,
                                'zipcode': zipcode,
                              };

                              // Add the address details to Firestore
                              await users.doc(userId).update({
                                'addressdetail': addressDetails,
                                'name': name,
                                'phone': phone,
                              });

                              // Clear text fields
                              addressController.clear();
                              cityController.clear();
                              stateController.clear();
                              zipcodeController.clear();
                              nameController.clear();
                              phoneController.clear();

                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            } else {
                              Fluttertoast.showToast(
                                msg: "Fill all the fields.",
                                toastLength: Toast.LENGTH_LONG,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.redAccent,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(87, 213, 236, 1),
                            minimumSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
