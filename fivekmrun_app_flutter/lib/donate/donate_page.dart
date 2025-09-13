import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fivekmrun_flutter/custom_icons.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.donate_page_title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 16.0, left: 16.0, top: 16),
              child: Column(children: [
                Center(
                    child: Text(
                  AppLocalizations.of(context)!.donate_page_description,
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
                            Text(AppLocalizations.of(context)!
                                .donate_page_become_a_patron),
                          ],
                        ),
                        onPressed: () async {
                          FirebaseAnalytics.instance
                              .logEvent(name: "button_donation_5kmrun_clicked");
                          await launch("https://5kmrun.bg/dariteli",
                              forceSafariVC: false);
                        },
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          AppLocalizations.of(context)!
                              .donate_page_patreon_description,
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
                          Text(AppLocalizations.of(context)!
                              .donate_page_pay_pal),
                        ],
                      ),
                      onPressed: () async {
                        FirebaseAnalytics.instance
                            .logEvent(name: "button_donation_paypal_clicked");
                        await launch(
                            "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=U9KNHBAU8VMFS&source=url",
                            forceSafariVC: false);
                      },
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(AppLocalizations.of(context)!
                          .donate_page_pay_pal_description),
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
                            Text(AppLocalizations.of(context)!
                                .donate_page_fan_store),
                          ],
                        ),
                        onPressed: () async {
                          FirebaseAnalytics.instance.logEvent(
                              name: "button_donation_fanshop_clicked");
                          await launch(
                              "https://www.bryzoshop.bg/bg-catalog-details-9.html",
                              forceSafariVC: false);
                        },
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(AppLocalizations.of(context)!
                            .donate_page_fan_store_description),
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
                            Text(AppLocalizations.of(context)!
                                .donate_page_xl_run),
                          ],
                        ),
                        onPressed: () async {
                          FirebaseAnalytics.instance
                              .logEvent(name: "button_donation_xlrun_clicked");
                          await launch("https://5kmrun.bg/xlrun/events",
                              forceSafariVC: false);
                        },
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(AppLocalizations.of(context)!
                            .donate_page_xl_run_description),
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
