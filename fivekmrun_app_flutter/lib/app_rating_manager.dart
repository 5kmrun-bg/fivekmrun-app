import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rate_my_app/rate_my_app.dart';

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
          FirebaseAnalytics().logEvent(name: "review_dialog_open");
          rateMyApp.showRateDialog(
            context,
            title: 'Харесвате ли приложението?', 
            message: 'Помогнете ни да го направим още по-добро, като оставите вашето мнение', 
            rateButton: 'Да, разбира се', 
            noButton: 'По-късно', 
            laterButton: 'Не, благодаря',
            ignoreIOS: false, // Set to false if you want to show the native Apple app rating dialog on iOS.
            listener: (button) { // The button click listener (useful if you want to cancel the click event).
              switch(button) {
                case RateMyAppDialogButton.rate:
                  FirebaseAnalytics().logEvent(name: "review_dialog_rate");
                  break;
                case RateMyAppDialogButton.later:
                  FirebaseAnalytics().logEvent(name: "review_dialog_later");
                  break;
                case RateMyAppDialogButton.no:
                  FirebaseAnalytics().logEvent(name: "review_dialog_cancel");
                  break;
              }
              return true;
            }
          );
        }
      });
    }
}