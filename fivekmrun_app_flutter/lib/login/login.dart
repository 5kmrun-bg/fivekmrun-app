import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fivekmrun_flutter/login/login_with_id.dart';
import 'package:fivekmrun_flutter/login/login_with_username.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool loginWithId = false;

  _toggleLogin() {
    this.setState(() => this.loginWithId = !this.loginWithId);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: Center(
        child: Container(
          width: 220,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              this._buildLogo(),
              SizedBox(height: 10),
              Spacer(),
              this.loginWithId ? LoginWithId() : LoginWithUsername(),
              SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  child:
                      Text(this.loginWithId ? AppLocalizations.of(context)!.login_widget_login_with_password : AppLocalizations.of(context)!.login_widget_login_with_id),
                  onPressed: this._toggleLogin,
                ),
              ),
              Spacer(),
              Text(AppLocalizations.of(context)!.login_widget_no_registration),
              GestureDetector(
                onTap: () => _loadRegistrationScreen(),
                child: Text(AppLocalizations.of(context)!.login_widget_register,
                    style: TextStyle(
                        color: accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
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

  _loadRegistrationScreen() async {
    print("load registration");
    FirebaseAnalytics.instance.logEvent(name: "open_registration_link");
    await launch("https://5kmrun.bg/register");
  }
}
