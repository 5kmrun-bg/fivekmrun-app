import 'package:flutter/material.dart';

class OfflineChartPage extends StatelessWidget {
  const OfflineChartPage({Key key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: Text("Офлайн Класация")),
      body: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.lightBlue),
          child: Text("Hello"),
        )
      ));
  }
}