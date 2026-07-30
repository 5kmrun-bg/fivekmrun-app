import 'package:fivekmrun_flutter/push_notifications_manager.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/local_storage_resource.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/whats_new/whats_new_page.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
                SizedBox(width: 12),
                LocaleSwitcherWidget(),
              ],
            ),
            Divider(color: dividerColor),
            InkWell(
              onTap: () => Navigator.of(context, rootNavigator: true)
                  .push(MaterialPageRoute(builder: (_) => WhatsNewPage())),
              child: Row(
                children: <Widget>[
                  Text(AppLocalizations.of(context)!.settings_page_whats_new),
                  Spacer(),
                  Icon(Icons.chevron_right),
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
        ));
  }
}
