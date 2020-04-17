import 'package:flutter/material.dart';

class OfflineChartPage extends StatefulWidget {
  OfflineChartPage({Key key}) : super(key: key);

  @override
  _OfflineChartPageState createState() => _OfflineChartPageState();
}

class _OfflineChartPageState extends State<OfflineChartPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Седмична офлайн класация'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
                onPressed: () => Navigator.of(context).pushNamed("/add"),
                child: Text("Участвай в класацията")),
          ],
        ),
      ),
    );
  }
}
