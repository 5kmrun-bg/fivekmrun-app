import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/user_resource.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userResource = Provider.of<UserResource>(context);
    final authenticationResource = Provider.of<AuthenticationResource>(context);

    final logout = () {
      userResource.reset();
      authenticationResource.logout();

      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil("/", (_) => false);
    };

    final goToDonation = () {
      Navigator.of(context, rootNavigator: true)
          .pushNamed("/donation");
    };

    return Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          title: Text("Настройки"),
          centerTitle: true,
        ),
        body: Column(children: <Widget>[
          Row(
            children: <Widget>[
              Text("Известия"),
              Switch(onChanged: (_) {}, value: true),
            ],
          ),
          Row(
            children: <Widget>[
              Text("Strava интеграция"),
              Switch(onChanged: (_) {}, value: true),
            ],
          ),
          Row(children: <Widget>[
            Text("Дарения"),
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: goToDonation,
            ),
          ]),
          Row(children: <Widget>[
            Text("Изход"),
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: logout,
            ),
          ])
        ]));
  }
}
