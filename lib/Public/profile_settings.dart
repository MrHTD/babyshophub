import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shimmer/shimmer.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    _user = _auth.currentUser;

    if (_user != null) {
      setState(() {
        emailController.text = _user!.email ?? '';
      });
    }
  }

  Future<void> _loadUserData() async {
    _user = _auth.currentUser;

    if (_user != null) {
      try {
        final userDoc =
            FirebaseFirestore.instance.collection('Users').doc(_user!.uid);

        DocumentSnapshot snapshot = await userDoc.get();

        if (snapshot.exists) {
          Map<String, dynamic>? userData =
              snapshot.data() as Map<String, dynamic>?;

          if (userData != null) {
            setState(() {
              print(userData['imageUrl'] ?? '');
            });
          } else {
            print('User data is null or not in the expected format.');
          }
        } else {
          print(
              'Snapshot does not exist. Check if data exists at the specified location.');
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> _saveUserData() async {
    _user = _auth.currentUser;

    if (_user != null) {
      try {
        final userDoc =
            FirebaseFirestore.instance.collection('Users').doc(_user!.uid);

        // Update image if a new image is selected
        if (imagePath != null) {
          await uploadImage(); // Upload the new image
          await userDoc.update({'imageUrl': imageUrl});
        }
        Fluttertoast.showToast(
          msg: "Profile Updated Successfully",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Failed to Update Profile",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print('Error saving user data: $e');
      }
    }
  }

  File? imagePath;
  String imageName = '';
  String imageData = '';
  String imageUrl = '';

  Future<String> getImageUrl(String userUid) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userUid);

      DocumentSnapshot snapshot = await userDoc.get();

      if (snapshot.exists) {
        // Assuming the value is stored as a string, adjust accordingly if it's stored differently
        return snapshot['imageUrl'] ?? '';
      } else {
        // Handle the case where the image URL is not found in the database
        return 'No Url Found';
      }
    } catch (e) {
      print('Error getting image URL: $e');
      return ''; // Return an empty string or some default value when an error occurs
    }
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> getImage() async {
    var pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        imagePath = File(pickedImage.path);
      });
    }
  }

  Future<void> uploadImage() async {
    if (imagePath != null) {
      try {
        // Generate a unique filename for the image
        String uniqueFilename =
            DateTime.now().millisecondsSinceEpoch.toString();
        String imageExtension = path.extension(imagePath!.path);
        String imageName = 'image_$uniqueFilename$imageExtension';

        final storageRef = FirebaseStorage.instance.ref();
        final imagesRef = storageRef.child("Images/$imageName");

        // Upload image to Firebase Storage
        await imagesRef.putFile(imagePath!);

        // Get the download URL for the uploaded image
        imageUrl = await imagesRef.getDownloadURL();

        // Store image information in Firestore
        await storeImageInfo(imageName, imageUrl);

        print('Image Uploaded Successfully');
      } catch (error) {
        print('Image Uploaded Failed');
        print("Error uploading image: $error");
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please choose an image first.",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> storeImageInfo(String imageName, String imageUrl) async {
    try {
      print('Storing image info: $imageName, $imageUrl');
      // await FirebaseFirestore.instance.collection('images').add({
      //   'name': imageName,
      //   'url': imageUrl,
      //   'timestamp': FieldValue.serverTimestamp(),
      // });
      print('Image info stored successfully');
    } catch (e) {
      print('Error storing image info: $e');
    }
  }

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
          "Edit Profile",
          style: TextStyle(
              color: Color.fromRGBO(87, 213, 236, 1),
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 0),
              Text(
                "Edit Your Image",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      getImage();
                    },
                    child: Container(
                      height: 190.0,
                      width: 190.0,
                      child: Stack(
                        children: [
                          Center(
                            child: imagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.file(imagePath!),
                                  )
                                : (_auth.currentUser != null
                                    ? FutureBuilder<String>(
                                        // Fetch the image URL based on the user's UID
                                        future:
                                            getImageUrl(_auth.currentUser!.uid),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                                  ConnectionState.waiting ||
                                              snapshot.connectionState ==
                                                  ConnectionState.none ||
                                              snapshot.data == null ||
                                              snapshot.data!.isEmpty) {
                                            return Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              direction: ShimmerDirection.ttb,
                                              child: Container(
                                                width: 190,
                                                height: 190,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return const Text(
                                                'Error loading image');
                                          } else if (snapshot.hasData &&
                                              snapshot.data!.isNotEmpty) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: Image.network(
                                                snapshot.data!,
                                                key:
                                                    UniqueKey(), // Force reload when the image changes
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          } else {
                                            // If no image URL is available, show a default image
                                            return Image.asset(
                                              'assets/images/usericon.png',
                                              fit: BoxFit.cover,
                                            );
                                          }
                                        },
                                      )
                                    : Image.asset(
                                        'assets/images/usericon.png',
                                        fit: BoxFit.cover,
                                      )),
                          ),
                          Positioned(
                            bottom: 25,
                            right: 25,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(
                                        0, 5), // changes position of shadow
                                  ),
                                ],
                                color: Colors.white.withOpacity(1),
                              ),
                              child: Center(
                                child: IconButton(
                                  alignment: Alignment.center,
                                  onPressed: () {
                                    getImage();
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color.fromRGBO(87, 213, 236, 1),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Positioned(
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    "You cannot change email",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              //email field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(209, 209, 209, 1),
                      blurRadius: 50,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Material(
                        elevation: 0,
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.name,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: "Enter Email",
                            fillColor: Colors.white,
                            filled: true,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //login btn
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveUserData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(87, 213, 236, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 1,
                      ),
                      child: const Text(
                        "Update",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
