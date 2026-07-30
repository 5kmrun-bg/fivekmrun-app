import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fivekmrun_flutter/login/helpers.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';

class LoginWithUsername extends StatefulWidget {
  /// True when this screen is adding an additional profile (#184) rather
  /// than starting the app's one and only session — the new profile is
  /// added without disturbing whichever profile is currently active, and
  /// success pops back to the caller instead of replacing the whole
  /// navigation stack with "home".
  final bool addingProfile;

  const LoginWithUsername({Key? key, this.addingProfile = false})
      : super(key: key);

  @override
  _LoginWithUsernameState createState() => _LoginWithUsernameState();
}

class _LoginWithUsernameState extends State<LoginWithUsername> {
  final usernameInputController = TextEditingController();
  final passwordInputController = TextEditingController();
  bool loginError = false;
  bool maxProfilesError = false;

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
        .authenticate(username, password, makeActive: !widget.addingProfile)
        .then((isAuthenticated) {
      // Best-effort, like the error-path reporting below: a telemetry
      // failure here must not be mistaken for an authentication failure by
      // the catchError below, which would otherwise show the wrong error
      // message despite a successful login.
      try {
        FirebaseCrashlytics.instance
            .log("authenticate with username result: $isAuthenticated");
      } catch (_) {}

      if (isAuthenticated) {
        if (mounted) {
          setState(() {
            this.loginError = false;
            this.maxProfilesError = false;
          });
        }
        if (widget.addingProfile) {
          try {
            FirebaseAnalytics.instance.logEvent(
                name: "profile_add", parameters: {"type": "password"});
          } catch (_) {}
          Navigator.of(context).pop(true);
        } else {
          try {
            FirebaseAnalytics.instance.logEvent(name: "login");
          } catch (_) {}
          Navigator.pushNamedAndRemoveUntil(context, "home", (_) => false);
        }
      } else {
        if (mounted) setState(() => this.loginError = true);
      }
    }).catchError((error, stackTrace) {
      if (error is MaxProfilesReachedException) {
        if (mounted) setState(() => this.maxProfilesError = true);
        return;
      }

      // Show the error before reporting it. Reporting alone left the tap with
      // no visible effect at all, indistinguishable from a request that is
      // merely slow. Every failure mode of authenticate() lands here — a
      // SocketException with no usable network, a FormatException when a
      // captive portal answers with HTML instead of JSON. Ordering also keeps
      // the user-facing feedback independent of the telemetry call.
      if (mounted) setState(() => this.loginError = true);

      // Best-effort: reporting must not become a second failure on top of the
      // one being reported. Crashlytics throws if Firebase never initialised,
      // and an exception raised here would escape as an unhandled async error.
      try {
        FirebaseCrashlytics.instance.recordError(error, stackTrace,
            reason: "authenticate with username");
      } catch (_) {}
    });
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
                AppLocalizations.of(context)!
                    .login_with_username_widget_wrong_auth,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          if (this.maxProfilesError)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              child: Text(
                AppLocalizations.of(context)!
                    .profile_switcher_max_profiles_reached,
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
            decoration: InputHelpers.decoration(AppLocalizations.of(context)!
                .login_with_username_widget_password),
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
