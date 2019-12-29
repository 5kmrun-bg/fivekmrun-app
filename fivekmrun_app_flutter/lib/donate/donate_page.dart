import 'package:flutter/material.dart';

class DonatePage extends StatelessWidget {
  const DonatePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Дарение")),
        body: Center(
          child: RaisedButton(
            child: Text("PayPal"),
            onPressed: () {
              // TODO: implement
            },
          ),
        ));
  }
}
