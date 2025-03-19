import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget customHomeButton(
  BuildContext context, {
  required String image,
  required String title,
  required VoidCallback onPressed,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        fixedSize: Size(MediaQuery.sizeOf(context).width * 0.8, 80),
      ),
      child: Row(
        children: [
          SizedBox(width: 10),
          Image.asset(image, width: 50),
          Spacer(),
          Text(title),
          Spacer(flex: 2),
        ],
      ),
    ),
  );
}

void navigateTo(BuildContext context, Widget screen) {
  Navigator.push(context, CupertinoPageRoute(builder: (context) => screen));
}
