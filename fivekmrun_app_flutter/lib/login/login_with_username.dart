import 'package:fivekmrun_flutter/login/input_helpers.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class LoginWithUsername extends StatefulWidget {
  @override
  _LoginWithUsernameState createState() => _LoginWithUsernameState();
}

class _LoginWithUsernameState extends State<LoginWithUsername> {
  final usernameInputController = TextEditingController();
  final passwordInputController = TextEditingController();
  bool loginError = false;

  @override
  void dispose() {
    this.usernameInputController.dispose();
    this.passwordInputController.dispose();
    super.dispose();
  }

  void onPressed() async {
    String username = this.usernameInputController.text.trim();
    String password = this.passwordInputController.text;

    Provider.of<AuthenticationResource>(context, listen: false)
        .authenticate(username, password)
        .then((isAuthenticated) {
      if (isAuthenticated) {
        int userId = Provider.of<AuthenticationResource>(context, listen: false).getUserId();

        setState(() => this.loginError = false);
        Provider.of<UserResource>(context, listen: false).currentUserId = userId;
        Navigator.pushNamed(context, '/home');
      } else {
        setState(() => this.loginError = true);
      }
    }).catchError((error, stackTrace) => print("ERROR: " + error.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 250,
        width: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Потребителско име",
              style: Theme.of(context).textTheme.title,
            ),
            if (this.loginError) 
              Text("Грешно потребителско име или парола", style: TextStyle(color: Theme.of(context).errorColor))
            ,
            TextField(
              autocorrect: false,
              textAlign: TextAlign.center,
              controller: this.usernameInputController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputHelpers.decoration(),
            ),
            TextField(
              autocorrect: false,
              textAlign: TextAlign.center,
              controller: this.passwordInputController,
              obscureText: true,
              decoration: InputHelpers.decoration(),
            ),
            SizedBox(
                width: 150,
                child:
                    RaisedButton(onPressed: onPressed, child: Text("Напред")))
          ],
        ));
  }
}
