import 'package:fivekmrun_flutter/push_notifications_manager.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/local_storage_resource.dart';
import 'package:fivekmrun_flutter/whats_new/whats_new_page.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'common/locale_switch.dart';
import 'common/profile_switcher.dart';
import 'common/strava_connect.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotificationsSubscribed = false;

  @override
  Widget build(BuildContext context) {
    final authResource =
        Provider.of<AuthenticationResource>(context, listen: false);
    final localStorage = LocalStorageResource();
    localStorage.isSubscribedForGeneral.then(
        (value) => setState(() => _pushNotificationsSubscribed = value));

    // Removes only the current profile — falls back to another saved
    // profile if one remains, or to the login screen if this was the last
    // one. Either way Settings itself is no longer the right screen to be
    // on: closing it back to Profile is what lets the user actually see
    // which profile (if any) they landed on, rather than silently staying
    // on a Settings screen that gives no indication anything changed.
    //
    // Only pop when a profile is left to fall back to: when none remain,
    // removeProfileFromSwitcher already replaces the *entire* navigation
    // stack with the login screen — popping again on top of that would
    // empty the Navigator's history outright (`context.mounted` isn't a
    // reliable guard here, since disposal of the old route isn't
    // necessarily flushed to the element tree the instant that call
    // returns).
    Future<void> logout() async {
      final userId = authResource.getUserId();
      if (userId == null) return;
      await removeProfileFromSwitcher(context, userId);
      if (authResource.activeProfileId != null && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    final dividerColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Colors.white),
          title: Text(AppLocalizations.of(context)!.settings_page_settings),
          centerTitle: true,
        ),
        body: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(AppLocalizations.of(context)!
                        .settings_page_notifications),
                    Switch(
                      onChanged: (value) {
                        final pushNotificationManager =
                            PushNotificationsManager.getInstance();
                        setState(
                            () => localStorage.isSubscrubedForGeneral = value);
                        _pushNotificationsSubscribed = value;
                        if (value) {
                          pushNotificationManager.subscribeTopic("general");
                        } else {
                          pushNotificationManager.unsubscribeTopic("general");
                        }
                      },
                      value: _pushNotificationsSubscribed,
                    )
                  ],
                ),
                Divider(color: dividerColor),
                Text(AppLocalizations.of(context)!.settings_page_strava),
                const StravaConnect(),
                Divider(color: dividerColor),
                Row(
                  children: <Widget>[
                    Text(AppLocalizations.of(context)!.settings_page_language),
                    const SizedBox(width: 12),
                    const LocaleSwitcherWidget(),
                  ],
                ),
                Divider(color: dividerColor),
                InkWell(
                  onTap: () => Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(builder: (_) => WhatsNewPage())),
                  child: Row(
                    children: <Widget>[
                      Text(AppLocalizations.of(context)!
                          .settings_page_whats_new),
                      const Spacer(),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
                Divider(color: dividerColor),
                Row(children: <Widget>[
                  Text(AppLocalizations.of(context)!.settings_page_exit),
                  IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: logout,
                  ),
                ]),
                Divider(color: dividerColor),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    return Text(
                      AppLocalizations.of(context)!
                          .settings_page_version(snapshot.data!.version),
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
              ]),
            )));
  }
}
