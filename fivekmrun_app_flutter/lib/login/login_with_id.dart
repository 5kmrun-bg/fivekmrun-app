import 'package:fivekmrun_flutter/login/helpers.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginWithId extends StatefulWidget {
  LoginWithId({Key? key}) : super(key: key);

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
    await Provider.of<AuthenticationResource>(context, listen: false)
        .authenticateWithUserId(userId);
    Provider.of<UserResource>(context, listen: false).currentUserId = userId;

    Navigator.pushNamed(context, 'loginPreview');
  }

  @override
  Widget build(BuildContext context) {
    final textStlyle = Theme.of(context).textTheme.titleSmall;
    final accentColor = Theme.of(context).colorScheme.secondary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TextField(
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
                style: textStlyle?.copyWith(
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
          child: ElevatedButton(onPressed: onPressed, child: Text("Напред")),
        ),
      ],
    );
  }
}
