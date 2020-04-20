import 'package:fivekmrun_flutter/login/helpers.dart';
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
    //Provider.of<UserResource>(context, listen: false).load(id: userId);
    // TODO: should we load all here
    //Provider.of<RunsResource>(context, listen: false).load(id: userId);
    Navigator.pushNamed(context, '/loginPreview');
  }

  void onPressedTest() async {
    int userId = int.parse(numberInputController.text);
    Provider.of<UserResource>(context, listen: false).getById(userId);
    Provider.of<RunsResource>(context, listen: false).getByUserId(userId);
  }

  @override
  Widget build(BuildContext context) {
    final textStlyle = Theme.of(context).textTheme.subtitle;
    final accentColor = Theme.of(context).accentColor;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TextField(
          textAlign: TextAlign.center,
          controller: numberInputController,
          keyboardType: TextInputType.number,
          decoration: InputHelpers.decoration("личен номер"),
        ),
        SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: textStlyle,
            children: <TextSpan>[
              TextSpan(text: 'Участието в '),
              TextSpan(
                text: 'Selfie',
                style: textStlyle.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: ' класацията е достъпно само с парола!'),
            ],
          ),
        ),
        SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: RaisedButton(onPressed: onPressed, child: Text("Напред")),
        ),
      ],
    );
  }
}
