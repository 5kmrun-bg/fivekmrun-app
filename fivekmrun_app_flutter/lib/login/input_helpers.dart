import 'package:flutter/material.dart';

class InputHelpers {
    static decoration() {
        return InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0))),
        );      
    }
}