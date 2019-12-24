import 'package:fivekmrun_flutter/common/avatar.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/milestone.dart';

class ProfileDashboard extends StatelessWidget {
  const ProfileDashboard({Key key}) : super(key: key);

  int nextRunsMilestone(int count) {
    if (count <= 50) {
      return 50;
    } else if (count <= 100) {
      return 100;
    } else if (count <= 250) {
      return 250;
    } else {
      return 500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserResource>(builder: (context, userResource, child) {
      final user = userResource?.value;
      final textTheme = Theme.of(context).textTheme;
      final logout = () {
        userResource.reset();
        Navigator.pushNamedAndRemoveUntil(context, "/", (_) {
          return false;
        });
      };
      return ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.line_weight),
                    onPressed: () {},
                  ),
                  MilestoneTile(
                      value: user?.totalKmRan?.toInt() ?? 0,
                      milestone: 1250,
                      title: "Пробягано\nразстояние"),
                ],
              ),
              Column(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Hero(tag: "avatar", child: Avatar(url: user?.avatarUrl)),
                  Text(user?.name ?? "", style: textTheme.body2),
                  Text("${user?.age ?? ""}г."),
                  Text("${user?.suuntoPoints ?? ""} SUUNTO точки"),
                ],
              ),
              Column(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: logout,
                  ),
                  MilestoneTile(
                      value: user?.runsCount ?? 0,
                      milestone: nextRunsMilestone(user?.runsCount ?? 0),
                      title: "Следаваща\nцел"),
                ],
              ),
            ],
          ),
        ],
      );
    });
  }
}
