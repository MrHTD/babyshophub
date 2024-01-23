// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:babyshophub/Public/login.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();

  String? _validatePhoneNumber(String? value) {
    if (value?.length != 11) {
      return 'Phone number must be 11 digits';
    }
    return null; // Return null if the validation passes
  }

  final databaseRef = FirebaseDatabase.instance.ref('Users');
  final _auth = FirebaseAuth.instance;

  Future<void> register() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailcontroller.text,
        password: passwordcontroller.text,
      );

      // Registration successful, save additional information to Firebase Realtime Database
      if (userCredential.user != null) {
        // Get the user ID
        String userId = userCredential.user!.uid;

        // Save image to Firebase Storage
        await uploadImage();

        // Save additional user information to Firestore
        await FirebaseFirestore.instance.collection('Users').doc(userId).set({
          'email': emailcontroller.text,
          'name': namecontroller.text,
          'phone': phonecontroller.text,
          'imageUrl': imageUrl,
          'role': 'public', // Set the default role
        });

        if (imagePath != null) {
          await uploadImage();
        }
        // Show toast and possibly navigate to another screen
        Fluttertoast.showToast(
          msg: "Registration Successful",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else if (emailcontroller.text.isEmpty ||
          namecontroller.text.isEmpty ||
          phonecontroller.text.isEmpty ||
          imagePath == null) {
        Fluttertoast.showToast(
          msg: "Fill All the Fields.",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      // Handle errors
      print(e);
      Fluttertoast.showToast(
        msg: "Registration Failed",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  //imagework
  File? imagePath;
  String imageName = '';
  String imageData = '';
  String imageUrl = '';

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> getImage() async {
    var pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        imagePath = File(pickedImage.path);
        String imageExtension = path.extension(pickedImage.path);
        imageName =
            'image_${DateTime.now().millisecondsSinceEpoch}$imageExtension';
        imageData = base64Encode(imagePath!.readAsBytesSync());
        print(imagePath);
      });
    }
  }

  Future<void> uploadImage() async {
    if (imagePath != null) {
      String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();
      String imageExtension = path.extension(imagePath!.path);

      final storageRef = FirebaseStorage.instance.ref();
      final imagesRef =
          storageRef.child("Images/$uniqueFilename$imageExtension");

      try {
        await imagesRef.putFile(imagePath!);
        imageUrl = await imagesRef.getDownloadURL();

        // Store image information in Firestore
        await storeImageInfo(imageName, imageUrl);

        print('Image Uploaded Successful');

        // // ignore: use_build_context_synchronously
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const ViewImage()),
        // );
      } catch (error) {
        Fluttertoast.showToast(
          msg: "Image Upload Failed.",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print("Error uploading image: $error");
      }
    } else {
      // Fluttertoast.showToast(
      //   msg: "Please choose an image first.",
      //   toastLength: Toast.LENGTH_LONG,
      //   timeInSecForIosWeb: 1,
      //   backgroundColor: Colors.redAccent,
      //   textColor: Colors.white,
      //   fontSize: 16.0,
      // );
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
      body: Form(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 70),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      getImage();
                    },
                    child: Container(
                      height: 160.0,
                      width: 160.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 5), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: imagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.file(imagePath!),
                                  )
                                : Image.asset(
                                    'assets/images/user.png',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            bottom: 25,
                            right: 25,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(209, 209, 209, 1),
                                    blurRadius: 50,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                                color: Colors.white.withOpacity(1),
                              ),
                              child: IconButton(
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Register your account",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              //Name fields in the same row
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    elevation: 0,
                    child: TextFormField(
                      controller: namecontroller,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: "Enter Name",
                        fillColor: Colors.white,
                        filled: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    elevation: 0,
                    child: TextFormField(
                      controller: emailcontroller,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: "Enter Email", // Hide label when selected
                        fillColor: Colors.white,
                        filled: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              //field 2
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    elevation: 0,
                    child: TextFormField(
                      controller: passwordcontroller,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: "Enter Password", // Hide label when selected
                        fillColor: Colors.white,
                        filled: true,

                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              //phone field
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    elevation: 0,
                    child: TextFormField(
                      controller: phonecontroller,
                      validator: _validatePhoneNumber,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: "Enter Phone no", // Hide label when selected
                        fillColor: Colors.white,
                        filled: true,
                        // errorText: "Phone number must be 11 digits",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Column(children: [
                ElevatedButton(
                  onPressed: () async {
                    if (namecontroller.text != '' &&
                        emailcontroller.text != '' &&
                        passwordcontroller.text != '' &&
                        passwordcontroller.text != '') {
                      register();
                    } else if (imagePath == null) {
                      Fluttertoast.showToast(
                        msg: "Fill All the Fields.",
                        toastLength: Toast.LENGTH_LONG,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.redAccent,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(87, 213, 236, 1),
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ]),
              //login btn
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already Have a account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                      );
                    },
                    child: const Text("Login"),
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
