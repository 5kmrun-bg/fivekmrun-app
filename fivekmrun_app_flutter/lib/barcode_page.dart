import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:barcode_flutter/barcode_flutter.dart';
import 'package:provider/provider.dart';

class BarcodePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserResource>(builder: (context, userResource, child) {
      final user = userResource?.value;

      return Scaffold(
          appBar: AppBar(
              leading: BackButton(color: Colors.white),
              title: Text("Barcode"),
              centerTitle: true,),
          backgroundColor: Colors.white,
          body: Center(child: Column(children: <Widget>[
            Text(user.name, style: TextStyle(color: Colors.black)),
            BarCodeImage(
                params: Code39BarCodeParams(
              user.id.toString().padLeft(10, '0'),
              lineWidth:
                  2.0, // width for a single black/white bar (default: 2.0)
              barHeight: 90.0, // height for the entire widget (default: 100.0)
              withText: false,
            )),
            Text(user.id.toString(), style: TextStyle(color: Colors.black))
          ])));
    });
  }
}
