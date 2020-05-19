import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DonatePage extends StatelessWidget {
  const DonatePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          title: Text("Дарение")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text("Това приложение и цялата дейност на 5kmRun се издържа изцяло от дарения и доброволен труд. Можете да подкрепите нашите усилия като дарите избрана от вас сума бързо, лесно и надеждно.", textAlign: TextAlign.center,)),
              ),
              RaisedButton(
                child: Text("Дари с PayPal"),
                onPressed: () async {
                  FirebaseAnalytics().logEvent(name: "button_donation_clicked");
                  await launch("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=U9KNHBAU8VMFS&source=url", forceSafariVC: false);
                },
              ),
            ],
          ),
        ));
  }
}
