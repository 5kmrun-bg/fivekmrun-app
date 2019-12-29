import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';

class RunDetailsPage extends StatelessWidget {
  const RunDetailsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Run run = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(title: Text(run.displayDate)),
      body: Center(
        child: Text(run.location),
      ),
    );
  }
}
