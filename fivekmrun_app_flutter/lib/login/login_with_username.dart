import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fivekmrun_flutter/login/helpers.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


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
      FirebaseCrashlytics.instance
          .log("authenticate with username result: $isAuthenticated");

      if (isAuthenticated) {
        FirebaseAnalytics.instance.logEvent(name: "login");
        setState(() => this.loginError = false);
        Navigator.pushNamedAndRemoveUntil(context, "home", (_) => false);
      } else {
        setState(() => this.loginError = true);
      }
    }).catchError((error, stackTrace) => print("ERROR: " + error.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (this.loginError)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              child: Text(
                AppLocalizations.of(context)!.login_with_username_widget_wrong_auth,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          TextField(
            autocorrect: false,
            controller: this.usernameInputController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: [AutofillHints.username],
            decoration: InputHelpers.decoration("email"),
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 10),
          TextField(
            controller: this.passwordInputController,
            autocorrect: false,
            obscureText: true,
            autofillHints: [AutofillHints.password],
            decoration: InputHelpers.decoration(AppLocalizations.of(context)!.login_with_username_widget_password),
            onEditingComplete: () => TextInput.finishAutofillContext(),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              child: Text(AppLocalizations.of(context)!.next),
            ),
          )
        ],
      ),
    );
  }
}
