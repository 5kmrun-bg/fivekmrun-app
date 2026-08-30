import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fivekmrun_flutter/common/locale_switch.dart';
import 'package:fivekmrun_flutter/login/login_with_id.dart';
import 'package:fivekmrun_flutter/login/login_with_username.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';

class Login extends StatefulWidget {
  /// True when reached via "Add profile" (#184) rather than the app's
  /// initial sign-in — swaps in an app bar (with a back button, since this
  /// is now a screen pushed on top of the switcher) and has the two login
  /// widgets add a profile instead of starting the one and only session.
  final bool addingProfile;

  const Login({Key? key, this.addingProfile = false}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool loginWithId = false;

  _toggleLogin() {
    setState(() => loginWithId = !loginWithId);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: widget.addingProfile
          ? AppBar(
              leading: const BackButton(color: Colors.white),
              title: Text(l10n.profile_switcher_add_profile),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: SizedBox(
                width: 220,
                height: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    if (!widget.addingProfile) ...[
                      _buildLogo(),
                      const SizedBox(height: 10),
                    ],
                    const Spacer(),
                    loginWithId
                        ? LoginWithId(addingProfile: widget.addingProfile)
                        : LoginWithUsername(
                            addingProfile: widget.addingProfile),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _toggleLogin,
                        child: Text(loginWithId
                            ? l10n.login_widget_login_with_password
                            : l10n.login_widget_login_with_id),
                      ),
                    ),
                    const Spacer(),
                    if (!widget.addingProfile) ...[
                      Text(l10n.login_widget_no_registration),
                      GestureDetector(
                        onTap: () => _loadRegistrationScreen(),
                        child: Text(l10n.login_widget_register,
                            style: TextStyle(
                                color: accentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ],
                ),
              ),
            ),
            if (!widget.addingProfile)
              const Positioned(
                top: 8,
                right: 8,
                child: LocaleSwitcherWidget(),
              ),
          ],
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
    FirebaseAnalytics.instance.logEvent(name: "open_registration_link");
    await launchUrl(Uri.parse("https://5kmrun.bg/register"));
  }
}
