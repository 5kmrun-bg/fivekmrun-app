import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class AppRatingManager {
  AppRatingManager(BuildContext context) {
    RateMyApp rateMyApp = new RateMyApp(
        preferencesPrefix: "kmrun_",
        minDays: 0,
        minLaunches: 3,
        remindDays: 0,
        remindLaunches: 7,
        appStoreIdentifier: "1299888204",
        googlePlayIdentifier: "bg.fivekmpark.fivekmrun");

    rateMyApp.init().then((_) {
      if (rateMyApp.shouldOpenDialog) {
        FirebaseAnalytics.instance.logEvent(name: "review_dialog_open");
        rateMyApp.showRateDialog(context,
            title: AppLocalizations.of(context)!.app_rating_manager_title,
            message:
            AppLocalizations.of(context)!.app_rating_manager_message,
            rateButton: AppLocalizations.of(context)!.app_rating_manager_rate_button,
            noButton: AppLocalizations.of(context)!.app_rating_manager_no_button,
            laterButton: AppLocalizations.of(context)!.app_rating_manager_later_button,
            //ignoreIOS: false, // Set to false if you want to show the native Apple app rating dialog on iOS.
            listener: (button) {
          // The button click listener (useful if you want to cancel the click event).
          switch (button) {
            case RateMyAppDialogButton.rate:
              FirebaseAnalytics.instance.logEvent(name: "review_dialog_rate");
              break;
            case RateMyAppDialogButton.later:
              FirebaseAnalytics.instance.logEvent(name: "review_dialog_later");
              break;
            case RateMyAppDialogButton.no:
              FirebaseAnalytics.instance.logEvent(name: "review_dialog_cancel");
              break;
          }
          return true;
        });
      }
    });
  }
}
