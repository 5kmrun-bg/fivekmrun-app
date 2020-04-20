import 'package:flutter/material.dart';

class InputHelpers {
  static InputDecoration decoration(String hint) {
    return InputDecoration(
      labelText: hint,
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(0))),
    );
  }
}