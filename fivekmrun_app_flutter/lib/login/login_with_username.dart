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
        int userId = Provider.of<AuthenticationResource>(context, listen: false)
            .getUserId();

        setState(() => this.loginError = false);
        Provider.of<UserResource>(context, listen: false).load(id: userId);
        // TODO: should we load all here
        Provider.of<RunsResource>(context, listen: false).load(id: userId);
        Navigator.pushNamed(context, '/home');
      } else {
        setState(() => this.loginError = true);
      }
    }).catchError((error, stackTrace) => print("ERROR: " + error.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        if (this.loginError)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: Text("Грешно потребителско име или парола",
                style: TextStyle(
                  color: Theme.of(context).errorColor,
                )),
          ),
        TextField(
          autocorrect: false,
          controller: this.usernameInputController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputHelpers.decoration("email"),
        ),
        SizedBox(height: 10),
        TextField(
          controller: this.passwordInputController,
          autocorrect: false,
          obscureText: true,
          decoration: InputHelpers.decoration("парола"),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: RaisedButton(
            onPressed: onPressed,
            child: Text("Напред"),
          ),
        )
      ],
    );
  }
}
