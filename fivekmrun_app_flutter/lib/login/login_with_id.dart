import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fivekmrun_flutter/login/helpers.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';

class LoginWithId extends StatefulWidget {
  /// See [LoginWithUsername.addingProfile] — same meaning here. An ID-only
  /// profile has no confirm-and-switch step of its own (unlike the initial
  /// login's "loginPreview"), so adding one just pops back to the caller on
  /// success without touching the currently active profile's data.
  final bool addingProfile;

  const LoginWithId({Key? key, this.addingProfile = false}) : super(key: key);

  @override
  _LoginWithIdState createState() => _LoginWithIdState();
}

class _LoginWithIdState extends State<LoginWithId> {
  final numberInputController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    numberInputController.dispose();
    super.dispose();
  }

  void onPressed() async {
    final l10n = AppLocalizations.of(context)!;
    final userId = parseUserId(numberInputController.text);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.login_with_id_widget_invalid_id)),
      );
      return;
    }

    if (widget.addingProfile) {
      try {
        await Provider.of<AuthenticationResource>(context, listen: false)
            .authenticateWithUserId(userId, makeActive: false);
      } on MaxProfilesReachedException {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profile_switcher_max_profiles_reached)),
        );
        return;
      }
      // Best-effort: a telemetry failure must not block completing the add.
      try {
        FirebaseAnalytics.instance
            .logEvent(name: "profile_add", parameters: {"type": "idOnly"});
      } catch (_) {}
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    await Provider.of<AuthenticationResource>(context, listen: false)
        .authenticateWithUserId(userId);
    Provider.of<UserResource>(context, listen: false).currentUserId = userId;

    Navigator.pushNamed(context, 'loginPreview');
  }

  @override
  Widget build(BuildContext context) {
    final textStlyle = Theme.of(context).textTheme.titleSmall;
    final accentColor = Theme.of(context).colorScheme.secondary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TextField(
          controller: numberInputController,
          keyboardType: TextInputType.number,
          decoration: InputHelpers.decoration(
              AppLocalizations.of(context)!.login_with_id_widget_personal_id),
        ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: textStlyle,
            children: <TextSpan>[
              TextSpan(
                  text: AppLocalizations.of(context)!
                      .login_with_id_widget_participation),
              TextSpan(
                text: 'Selfie',
                style: textStlyle?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                  text: AppLocalizations.of(context)!
                      .login_with_id_widget_authentication),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              onPressed: onPressed,
              child: Text(AppLocalizations.of(context)!.next)),
        ),
      ],
    );
  }
}
