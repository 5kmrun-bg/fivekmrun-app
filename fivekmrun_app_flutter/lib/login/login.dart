import 'package:fivekmrun_flutter/login/login_with_id.dart';
import 'package:fivekmrun_flutter/login/login_with_username.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool loginWithId = false;

  _toggleLogin() {
    this.setState(() => {this.loginWithId = !this.loginWithId});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              this._buildLogo(),
              SizedBox(height: 10),
              this.loginWithId ? LoginWithId() : LoginWithUsername(),
              SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: OutlineButton(
                  child:
                      Text(this.loginWithId ? "влез с парола" : "влез с номер"),
                  onPressed: this._toggleLogin,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Image.asset(
        'assets/logo.png',
        width: 120,
        height: 120,
      ),
    );
  }
}
