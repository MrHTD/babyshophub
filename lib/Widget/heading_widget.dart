import 'package:flutter/material.dart';

class HeadingWidget extends StatelessWidget {
  final String headingtitle;
  final VoidCallback onPressed;
  final String buttontext;

  const HeadingWidget({
    super.key,
    required this.headingtitle,
    required this.onPressed,
    required this.buttontext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              headingtitle,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            TextButton(
              onPressed: onPressed,
              child: Text(
                buttontext,
                style: const TextStyle(
                  color: Color.fromRGBO(87, 213, 236, 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
