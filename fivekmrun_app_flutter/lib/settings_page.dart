import 'package:fivekmrun_flutter/push_notifications_manager.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/local_storage_resource.dart';
import 'package:fivekmrun_flutter/state/locale_provider.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'common/locale_switch.dart';
import 'common/strava_connect.dart';
import 'state/user_resource.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotificationsSubscribed = false;

  @override
  Widget build(BuildContext context) {
    final authResource =
        Provider.of<AuthenticationResource>(context, listen: false);
    final localStorage = new LocalStorageResource();
    localStorage.isSubscribedForGeneral.then(
        (value) => setState(() => this._pushNotificationsSubscribed = value));

    final logout = () async {
      await authResource.logout();
      Provider.of<UserResource>(context, listen: false).clear();
      Provider.of<RunsResource>(context, listen: false).clear();
      Provider.of<LocaleProvider>(context, listen: false).clearLocale();

      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil("/", (_) => false);
    };

    final dividerColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          title: Text(AppLocalizations.of(context)!.settings_page_settings),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: <Widget>[
            Row(
              children: <Widget>[
                Text(AppLocalizations.of(context)!.settings_page_notifications),
                Switch(
                  onChanged: (value) {
                    print("SET PUSH NOTIFICATION: " + value.toString());
                    final pushNotificationManager =
                        PushNotificationsManager.getInstance();
                    setState(() => localStorage.isSubscrubedForGeneral = value);
                    this._pushNotificationsSubscribed = value;
                    if (value) {
                      pushNotificationManager.subscribeTopic("general");
                    } else {
                      pushNotificationManager.unsubscribeTopic("general");
                    }
                  },
                  value: this._pushNotificationsSubscribed,
                )
              ],
            ),
            Divider(color: dividerColor),
            Text(AppLocalizations.of(context)!.settings_page_strava),
            StravaConnect(),
            Divider(color: dividerColor),
            Row(
              children: <Widget>[
                Text(AppLocalizations.of(context)!.settings_page_language),
                LocaleSwitcherWidget(),
              ],
            ),
            Divider(color: dividerColor),
            Row(children: <Widget>[
              Text(AppLocalizations.of(context)!.settings_page_exit),
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: logout,
              ),
            ])
          ]),
        ));
  }
}
