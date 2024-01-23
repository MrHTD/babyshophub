import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cardHolderNameController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color.fromRGBO(87, 213, 236, 1),
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
        surfaceTintColor: const Color.fromRGBO(241, 244, 248, 1),
        centerTitle: true,
        title: const Text(
          "Add Payment Method",
          style: TextStyle(
              color: Color.fromRGBO(87, 213, 236, 1),
              fontWeight: FontWeight.bold),
        ),
        actions: [
          // Add your edit button here
          IconButton(
            icon: const Icon(
              Icons.add_rounded,
              color: Color.fromRGBO(87, 213, 236, 1),
            ),
            onPressed: () {
              _addCard(context);
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
                return const Text("No Card Details found");
              }

              Map<String, dynamic> userData =
                  snapshot.data!.data() as Map<String, dynamic>;

              // Check if the user has address details
              if (userData.containsKey('carddetail')) {
                Map<String, dynamic> cardDetails = userData['carddetail'];
                return buildAddressCard(cardDetails);
              } else {
                return const Center(
                  child: Text("No Card Details found"),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void combineText() {
    String combinedText =
        '${cardNumberController.text} ${cardHolderNameController.text} ${expiryDateController.text} ${cvvController.text}';
    print('Combined Text: $combinedText');
  }

  bool isExpiryDateValid(String value) {
    if (value.length != 5) {
      return false;
    }

    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;

    final month = int.tryParse(value.substring(0, 2));
    final year = int.tryParse(value.substring(3));

    return month != null &&
        month >= 1 &&
        month <= 12 &&
        year != null &&
        year >= currentYear && // Check if the year is not in the past
        !(year == currentYear &&
            month <
                currentMonth); // Check if the month is not in the past of the current year
  }

  Widget buildAddressCard(Map<String, dynamic> cardDetails) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          _addCard(context);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 00, 00, 00),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CreditCardWidget(
                cardNumber: cardDetails['cardnumber'],
                expiryDate: cardDetails['expirydate'],
                cardHolderName: cardDetails['holdername'],
                cvvCode: cardDetails['cvv'],
                bankName: getCardTypeName(cardDetails), // Use your method here
                showBackView: false,
                cardBgColor: Colors.blueGrey,
                onCreditCardWidgetChange: (CreditCardBrand brand) {},
                obscureCardNumber: false,
                obscureCardCvv: false,
                isHolderNameVisible: true,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.25,
                isChipVisible: true,
                isSwipeGestureEnabled: true,
                animationDuration: const Duration(milliseconds: 1000),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addCard(BuildContext context) {
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

              // Extract existing address details
              String existingCardNumber = userData.containsKey('carddetail')
                  ? userData['carddetail']['cardnumber'] ?? ''
                  : '';
              String existingName = userData.containsKey('carddetail')
                  ? userData['carddetail']['holdername'] ?? ''
                  : '';
              String existingExpirtDate = userData.containsKey('carddetail')
                  ? userData['carddetail']['expirydate'] ?? ''
                  : '';
              String existingCvv = userData.containsKey('carddetail')
                  ? userData['carddetail']['cvv'] ?? ''
                  : '';

              // Set existing values to text controllers
              cardNumberController.text = existingCardNumber;
              cardHolderNameController.text = existingName;
              expiryDateController.text = existingExpirtDate;
              cvvController.text = existingCvv;

              return ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Card',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: cardNumberController,
                                maxLength: 19,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(19),
                                  CreditCardNumberInputFormatter(),
                                ],
                                decoration: InputDecoration(
                                  hintText: "Credit Card Number",
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a valid credit card number';
                                  }
                                  if (value.length < 16) {
                                    return 'Credit card number must be at least 16 digits';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: cardHolderNameController,
                                decoration: InputDecoration(
                                  hintText: 'Cardholder Name',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter the cardholder name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: expiryDateController,
                                      maxLength: 5,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(5),
                                        ExpiryDateInputFormatter(),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: 'Expiry Date (MM/YY)',
                                        hintStyle:
                                            const TextStyle(fontSize: 14),
                                        fillColor: Colors.white,
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter the expiry date';
                                        }
                                        if (!isExpiryDateValid(value)) {
                                          return 'Invalid expiry date';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: cvvController,
                                      maxLength: 3,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        hintText: 'CVV',
                                        fillColor: Colors.white,
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter the CVV';
                                        }
                                        if (value.length < 3) {
                                          return 'CVV must be at least 3 digits';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                // onPressed: () {
                                //   // if (_formKey.currentState!.validate()) {
                                //   //   // Form is valid, proceed with combining and sending
                                //   //   combineText();
                                //   // }
                                // },
                                onPressed: () async {
                                  if (cardNumberController.text.isNotEmpty &&
                                      cardHolderNameController
                                          .text.isNotEmpty &&
                                      expiryDateController.text.isNotEmpty &&
                                      cvvController.text.isNotEmpty) {
                                    String cardnumber =
                                        cardNumberController.text.trim();
                                    String holdername =
                                        cardHolderNameController.text.trim();
                                    String expirydate =
                                        expiryDateController.text.trim();
                                    String cvv = cvvController.text.trim();

                                    String userId = user!.uid;

                                    // Reference to the users collection in Firestore
                                    CollectionReference users =
                                        FirebaseFirestore.instance
                                            .collection('Users');

                                    // Construct the address details
                                    Map<String, dynamic> cardDetails = {
                                      'cardnumber': cardnumber,
                                      'holdername': holdername,
                                      'expirydate': expirydate,
                                      'cvv': cvv,
                                    };

                                    // Add the address details to Firestore
                                    await users.doc(userId).update({
                                      'carddetail': cardDetails,
                                    });

                                    // Clear text fields
                                    cardNumberController.clear();
                                    cardHolderNameController.clear();
                                    expiryDateController.clear();
                                    cvvController.clear();

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
                                  'Add Credit Card',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
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

//card type
  String getCardTypeName(Map<String, dynamic> cardDetails) {
    String cardNumber =
        cardDetails['cardnumber'].toString().replaceAll(' ', '');

    if (RegExp(r'^4[0-9]{12}(?:[0-9]{3})?$').hasMatch(cardNumber)) {
      return 'Visa';
    } else if (RegExp(r'^5[1-5][0-9]{14}$').hasMatch(cardNumber)) {
      return 'MasterCard';
    } else if (RegExp(r'^3[47][0-9]{13}$').hasMatch(cardNumber)) {
      return 'American Express';
    } else if (RegExp(r'^6(?:011|5[0-9]{2})[0-9]{12}$').hasMatch(cardNumber)) {
      return 'Discover';
    } else if (RegExp(r'^3(?:0[0-5]|[68][0-9])[0-9]{11}$')
        .hasMatch(cardNumber)) {
      return 'Diners Club';
    } else if (RegExp(r'^62[0-9]{14,17}$').hasMatch(cardNumber)) {
      return 'UnionPay';
    } else {
      return 'Other';
    }
  }
}

class CreditCardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    // Remove any spaces in the entered text
    text = text.replaceAll(' ', '');

    // Insert a space after every 4 characters
    for (int i = 4; i < text.length; i += 5) {
      if (text[i] != ' ') {
        text = '${text.substring(0, i)} ${text.substring(i)}';
      }
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (text.length > 2 && !text.contains('/')) {
      // Insert '/' after the 2nd character
      text = '${text.substring(0, 2)}/${text.substring(2, text.length)}';
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
