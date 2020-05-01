import 'package:fivekmrun_flutter/push_notifications_manager.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/local_storage_resource.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/strava_connect.dart';
import 'state/user_resource.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

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
    localStorage.isSubscribedForGeneral
        .then((value) => this._pushNotificationsSubscribed = value);

    final logout = () async {
      await authResource.logout();
      Provider.of<UserResource>(context, listen: false).clear();
      Provider.of<RunsResource>(context, listen: false).clear();

      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil("/", (_) => false);
    };

    final goToDonation = () {
      Navigator.of(context, rootNavigator: true).pushNamed("/donation");
    };

    final dividerColor = Theme.of(context).accentColor;

    return Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          title: Text("Настройки"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: <Widget>[
            Row(
              children: <Widget>[
                Text("Известия"),
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
            Text("Strava интеграция"),
            StravaConnect(),
            Divider(color: dividerColor),
            Row(children: <Widget>[
              Text("Дарения"),
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: goToDonation,
              ),
            ]),
            Divider(color: dividerColor),
            Row(children: <Widget>[
              Text("Изход"),
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: logout,
              ),
            ])
          ]),
        ));
  }
}
