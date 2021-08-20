import 'package:fivekmrun_flutter/common/avatar.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPreview extends StatelessWidget {
  LoginPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserResource>(builder: (context, userResource, child) {
      final user = userResource.value;
      final title =
          user != null ? "${user.name} ${user.age}г." : "зареждане ...";
      final avatrUrl = user?.avatarUrl;
      final textTheme = Theme.of(context).textTheme;
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Влез като", style: textTheme.headline6),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(title, style: textTheme.headline6),
              ),
              Hero(tag: "avatar", child: Avatar(url: avatrUrl ?? "")),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Container(
                      width: 60,
                      child: ElevatedButton(
                        child: Icon(
                          Icons.edit,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: 150,
                    child: ElevatedButton(
                        child: Text("Напред"),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/home", (_) => false);
                        }),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
