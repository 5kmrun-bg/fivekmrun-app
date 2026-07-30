import 'package:collection/collection.dart';
import 'package:fivekmrun_flutter/common/refresh_helper.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/login/helpers.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/profile_model.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/strava_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Clears and reloads every *per-user* resource for whichever profile is now
/// active — [UserResource], [RunsResource] and the Strava connection. Device
/// settings (push notifications, locale, theme — `LocalStorageResource`,
/// `LocaleProvider`) are untouched, by design: switching profiles must never
/// reset those.
///
/// The Strava connection is disconnected rather than swapped: `strava_client`
/// keeps its own OAuth session in its own storage, keyed by nothing of ours,
/// so there is no way to hold two profiles' Strava connections at once
/// without reaching into that package's internals. Disconnecting avoids
/// silently attributing one profile's Strava activities to another.
void resetAndReloadForActiveProfile(BuildContext context) {
  final authRes = Provider.of<AuthenticationResource>(context, listen: false);
  final userRes = Provider.of<UserResource>(context, listen: false);
  final runsRes = Provider.of<RunsResource>(context, listen: false);
  final stravaRes = Provider.of<StravaResource>(context, listen: false);

  userRes.clear();
  runsRes.clear();
  reportOnFailure(
      stravaRes.deAuthenticate(), "strava deauth on profile switch");

  final newUserId = authRes.getUserId();
  userRes.currentUserId = newUserId;
  if (newUserId != null) {
    reportOnFailure(runsRes.getByUserId(newUserId), "runs");
    // Piggybacks a second fetch of the same endpoint rather than trying to
    // observe the one `currentUserId`'s setter already kicked off: that
    // setter notifies listeners twice (once for its own barcode-only
    // placeholder, again once the real data lands), and the two are
    // indistinguishable from here without deeper changes to UserResource.
    reportOnFailure(
      userRes.getById(newUserId, true).then((user) {
        if (user != null) {
          authRes.updateProfileDisplay(newUserId,
              name: user.name, avatarUrl: user.avatarUrl);
        }
      }),
      "user profile cache for switcher",
    );
  }
}

/// Switches to [userId], prompting for that profile's password first if its
/// token has expired — returns whether the switch completed (false if the
/// profile doesn't exist, or the user cancelled/failed the password prompt).
Future<bool> switchToProfile(BuildContext context, int userId) async {
  final authRes = Provider.of<AuthenticationResource>(context, listen: false);
  final profile = authRes.profiles.firstWhereOrNull((p) => p.userId == userId);
  if (profile == null) return false;

  if (profile.type == ProfileType.password && profile.isTokenExpired) {
    final reauthed = await showDialog<bool>(
      context: context,
      builder: (context) => _ReauthDialog(profile: profile),
    );
    if (reauthed != true) return false;
  } else {
    final switched = await authRes.switchProfile(userId);
    if (!switched) return false;
  }

  if (!context.mounted) return true;
  resetAndReloadForActiveProfile(context);
  // Best-effort: a telemetry failure must not surface as if the switch
  // itself failed — the switch and resource reset above already succeeded.
  try {
    FirebaseAnalytics.instance.logEvent(
        name: "profile_switch", parameters: {"type": profile.type.name});
  } catch (_) {}
  return true;
}

/// Removes [userId] from the switcher. If it was the active profile, falls
/// back to another saved profile (reloading per-user data for it), or — if
/// none remain — pops back to the login screen entirely.
Future<void> removeProfileFromSwitcher(BuildContext context, int userId) async {
  final authRes = Provider.of<AuthenticationResource>(context, listen: false);
  final removedType =
      authRes.profiles.firstWhereOrNull((p) => p.userId == userId)?.type;
  final wasActive = authRes.activeProfileId == userId;

  final newActiveId = await authRes.removeProfile(userId);

  // Best-effort — see switchToProfile's identical guard.
  try {
    FirebaseAnalytics.instance.logEvent(
      name: "profile_remove",
      parameters: {"type": removedType?.name ?? "unknown"},
    );
  } catch (_) {}

  if (!wasActive) return;
  if (!context.mounted) return;

  if (newActiveId == null) {
    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil("/", (_) => false);
  } else {
    resetAndReloadForActiveProfile(context);
  }
}

/// Prompts for a password (and, for a profile with no stored email — a
/// pre-multi-profile migrated profile — the email too) to refresh an expired
/// password profile's token, then performs the switch itself. Pops `true` on
/// success, `null`/`false` on cancel or a failed attempt (the dialog stays
/// open on failure so it can be retried).
class _ReauthDialog extends StatefulWidget {
  final Profile profile;

  const _ReauthDialog({Key? key, required this.profile}) : super(key: key);

  @override
  State<_ReauthDialog> createState() => _ReauthDialogState();
}

class _ReauthDialogState extends State<_ReauthDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  bool _error = false;

  bool get _needsUsername => widget.profile.username == null;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = false;
    });

    final authRes = Provider.of<AuthenticationResource>(context, listen: false);
    final success = await authRes.reauthenticateAndSwitch(
      widget.profile.userId,
      _passwordController.text,
      username: _needsUsername ? _usernameController.text.trim() : null,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _submitting = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = widget.profile.name.isNotEmpty
        ? widget.profile.name
        : widget.profile.userId.toString();

    return AlertDialog(
      title: Text(l10n.profile_switcher_reauth_title(label)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_error)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                l10n.profile_switcher_reauth_error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_needsUsername)
            TextField(
              controller: _usernameController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputHelpers.decoration("email"),
            ),
          if (_needsUsername) const SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputHelpers.decoration(
                l10n.login_with_username_widget_password),
            onSubmitted: (_) => _submitting ? null : _submit(),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.next),
        ),
      ],
    );
  }
}
