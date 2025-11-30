import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fivekmrun_flutter/custom_icons.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DonatePage extends StatelessWidget {
  const DonatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ButtonStyle secondaryStyle = ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        side: BorderSide(
          width: 1.0,
          color: Colors.white,
        ));

    return Scaffold(
      appBar: AppBar(title: Text("Подкрепи ни")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 16.0, left: 16.0, top: 16),
              child: Column(children: [
                Center(
                    child: Text(
                  "Това приложение и цялата дейност на 5kmRun се издържа изцяло от дарения и доброволен труд. Можете да подкрепите нашите усилия, чрез някой от изброените по-долу начини.",
                  textAlign: TextAlign.center,
                )),
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Row(children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 120),
                      child: ElevatedButton(
                        child: Row(
                          children: [
                            Text("Стани Патрон"),
                          ],
                        ),
                        onPressed: () async {
                          FirebaseAnalytics.instance
                              .logEvent(name: "button_donation_5kmrun_clicked");
                          await launchUrl(
                              Uri.parse("https://5kmrun.bg/dariteli"),
                              mode: LaunchMode.externalApplication);
                        },
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Можете да направите годишно дарение на стойност 24лв., което ще ви отреди званието 'Патрон' за следващите 12 месеца. Сумата можете да дарите на място при същинските бягания или по банков път.",
                        ),
                      ),
                    ),
                  ]),
                ),
                Row(children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 120),
                    child: ElevatedButton(
                      style: secondaryStyle,
                      child: Row(
                        children: [
                          Icon(CustomIcons.paypal, size: 16),
                          Text(" PayPal"),
                        ],
                      ),
                      onPressed: () async {
                        FirebaseAnalytics.instance
                            .logEvent(name: "button_donation_paypal_clicked");
                        await launchUrl(
                            Uri.parse(
                                "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=U9KNHBAU8VMFS&source=url"),
                            mode: LaunchMode.externalApplication);
                      },
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          "Можете да направите еднократно или регулярно дарение на сума по ваш избор."),
                    ),
                  )
                ]),
                Row(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 120),
                      child: ElevatedButton(
                        style: secondaryStyle,
                        child: Row(
                          children: [
                            Icon(Icons.shopping_bag),
                            Text(" Фен магазин"),
                          ],
                        ),
                        onPressed: () async {
                          FirebaseAnalytics.instance.logEvent(
                              name: "button_donation_fanshop_clicked");
                          await launchUrl(
                              Uri.parse(
                                  "https://bryzosport.com/bg-bg/pages/5-km-run"),
                              mode: LaunchMode.externalApplication);
                        },
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "Всяка покупка на артикул на нашия фен магазин подпомага дейностите на 5kmrun и ни помага да стигнем безплатно до хиляди хора в България."),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 120),
                      child: ElevatedButton(
                        style: secondaryStyle,
                        child: Row(
                          children: [
                            Icon(Icons.directions_run),
                            Text(" XL бягане"),
                          ],
                        ),
                        onPressed: () async {
                          FirebaseAnalytics.instance
                              .logEvent(name: "button_donation_xlrun_clicked");
                          await launchUrl(
                              Uri.parse("https://5kmrun.bg/xlrun/events"),
                              mode: LaunchMode.externalApplication);
                        },
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "Всеки месец в района на София организираме предизвикателства в различни дължини, терени и натоварвания. Таксата за участие изцяло подпомага дейностите на 5kmrun."),
                      ),
                    )
                  ],
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
