import 'package:fivekmrun_flutter/state/future_events_resource.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
    Provider.of<FutureEventsResource>(context, listen: false).load(force: true);
    Navigator.pushNamed(context, '/loginPreview');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 150,
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Личен номер", style: Theme.of(context).textTheme.title),
              TextField(
                textAlign: TextAlign.center,
                controller: numberInputController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0))),
                ),
              ),
              SizedBox(
                  width: 150,
                  child:
                      RaisedButton(onPressed: onPressed, child: Text("Напред")))
            ],
          ),
        ),
      ),
    );
  }
}
