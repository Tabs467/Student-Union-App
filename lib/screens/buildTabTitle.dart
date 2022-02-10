import 'package:flutter/material.dart';

Material buildTabTitle(String title, double fontSize) {
  return Material(
    elevation: 20,
    child: Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          color: Color.fromRGBO(22, 66, 139, 1),
          border: Border(
            bottom: BorderSide(
              width: 1.5,
              color: Color.fromRGBO(31, 31, 31, 1.0),
            ),
          )
      ),

      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Text(
            title,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}