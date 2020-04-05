import 'package:fivekmrun_flutter/common/milestone_gauge.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RunDetailsPage extends StatelessWidget {
  const RunDetailsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Run run = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(title: Text(run.displayDate)),
      body: Column(children: <Widget>[
        Row(children: <Widget>[
          Column(children: <Widget>[
            Text(run.pace.toString()),
            Text("Темпо"),],), 
          Column(children: <Widget>[
            MilestoneGauge(run.position, 400),
            Text("Позиция"),],),
          Column(children: <Widget>[
            Text(run.speed.toString()),
            Text("Скорост")],),
        ],),
        Row(children: <Widget>[
          Text(new DateFormat("dd.MM.yyyy").format(run.date)),
          Text(run.time),],),
        Text(run.location),
        Row(children: <Widget>[
          Text("Предишно бягане: "),
          Text(run.differenceFromPrevious),],),
        Row(children: <Widget>[
          Text("Най-добро бягане: "),
          Text(run.differenceFromBest)],),
      ],),
    );
  }
}
