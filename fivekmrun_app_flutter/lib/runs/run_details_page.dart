import 'package:fivekmrun_flutter/common/constants.dart';
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
        body: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child:
                  Column(
                    children: <Widget>[
                      CircleWidget(run.pace.toString(), "мин/км"),
                      Text("Темпо"),
                    ],
                  )),
                  Expanded(
                    flex: 4,
                    child: Column(
                    children: <Widget>[
                      MilestoneGauge(run.position, 400),
                      Text("Позиция"),
                    ],
                  )),
                  Expanded(
                    flex: 3,
                    child: Column(
                    children: <Widget>[
                      CircleWidget(run.speed.toString(), "км/ч"),
                      Text("Скорост")
                    ],
                  )),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(new DateFormat(Constants.DATE_FORMAT).format(run.date)),
                  Text(run.time),
                ],
              ),
              Text(run.location),
              Row(
                children: <Widget>[
                  Text("Предишно бягане: "),
                  Text(run.differenceFromPrevious),
                ],
              ),
              Row(
                children: <Widget>[
                  Text("Най-добро бягане: "),
                  Text(run.differenceFromBest)
                ],
              ),
            ],
          ),
        );
  }
}

class CircleWidget extends StatelessWidget {
  final String value;
  final String measurement;

  CircleWidget(this.value, this.measurement);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        children: <Widget>[
          Text(
            this.value,
            style: TextStyle(color: Colors.black),
          ),
          Text(
            this.measurement, 
            style: TextStyle(color: Colors.black))
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
