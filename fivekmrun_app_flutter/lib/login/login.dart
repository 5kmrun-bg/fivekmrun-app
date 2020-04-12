import 'package:fivekmrun_flutter/login/login_with_id.dart';
import 'package:fivekmrun_flutter/login/login_with_username.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      children: <Widget>[
        Container(height: 200), 
        LoginWithUsername(),
        LoginWithId()],
    )));
  }
}
