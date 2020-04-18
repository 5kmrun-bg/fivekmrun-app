import 'package:fivekmrun_flutter/login/input_helpers.dart';
import 'package:fivekmrun_flutter/state/new_runs_resource.dart';
import 'package:fivekmrun_flutter/state/new_user_resource.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class LoginWithId extends StatefulWidget {
  LoginWithId({Key key}) : super(key: key);

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
    int userId = int.parse(numberInputController.text);
    Provider.of<UserResource>(context, listen: false).load(id: userId);
    // TODO: should we load all here
    Provider.of<RunsResource>(context, listen: false).load(id: userId);
    Navigator.pushNamed(context, '/loginPreview');
  }

  void onPressedTest() async {
    int userId = int.parse(numberInputController.text);
    Provider.of<NewUserResource>(context, listen: false).getById(userId);
    Provider.of<NewRunsResource>(context, listen: false).getByUserId(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 150,
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Личен номер", style: Theme.of(context).textTheme.title),
              TextField(
                textAlign: TextAlign.center,
                controller: numberInputController,
                keyboardType: TextInputType.number,
                decoration: InputHelpers.decoration(),
              ),
              SizedBox(
                  width: 150,
                  child:
                      RaisedButton(onPressed: onPressed, child: Text("Напред"))),
              SizedBox(
                  width: 150,
                  child:
                      RaisedButton(onPressed: onPressedTest, child: Text("Тест"))),
            ],
          ),
    );
  }
}
