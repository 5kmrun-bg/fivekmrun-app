import 'dart:io';

import 'package:barcode_widgets/barcode_flutter.dart';
import 'package:add_to_google_wallet/widgets/add_to_google_wallet_button.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BarcodePage extends StatelessWidget {
  final Uuid uuid = Uuid();
  final issuerId = '3388000000022281825';
  final classId = 'MembershipCard';

  @override
  Widget build(BuildContext context) {
    return Consumer<UserResource>(builder: (context, userResource, child) {
      final user = userResource.value;
      final userId = (user?.id != null) ? user?.id : 0;
      final userName = (user?.name != null) ? user?.name : "";
      final isUserPatron = (userResource.value?.donationsCount ?? 0) > 0;

      final userStatus = isUserPatron ? AppLocalizations.of(context)!.barcode_page_patron : AppLocalizations.of(context)!.barcode_page_runner;
      final accentColor = Theme.of(context).colorScheme.secondary;

      final objectId = uuid.v4();
      final pass = """
        {
          "iss": "office@5kmrun.bg",
          "aud": "google",
          "typ": "savetowallet",
          "iat": 1699292701,
          "payload": {
            "genericObjects": [
              {
                "id": "$issuerId.$objectId",
                "classId": "$issuerId.$classId",
                "logo": {
                  "sourceUri": {
                    "uri": "https://firebasestorage.googleapis.com/v0/b/kmrunbg.appspot.com/o/1024.png?alt=media&token=bf61b9eb-8369-426b-8d80-2f5ad4036391"
                  }
                },
                "cardTitle": {
                  "defaultValue": {
                    "language": "en-US",
                    "value": "5kmrun"
                  }
                },
                "subheader": {
                  "defaultValue": {
                    "language": "en-US",
                    "value": "$userStatus"
                  }
                },
                "header": {
                  "defaultValue": {
                    "language": "en-US",
                    "value": "$userName"
                  }
                },
                "barcode": {
                  "type": "CODE_39",
                  "value": "${formatBarcode(userId)}",
                  "alternateText": "$userId"
                },
                "hexBackgroundColor": "#e01f23"
              }
            ]
          }
        }
      """;

      Widget buildButton() {
        if (Platform.isAndroid) {
          return AddToGoogleWalletButton(
            pass: pass,
            onSuccess: () => FirebaseAnalytics.instance
                .logEvent(name: "button_add_to_wallet_clicked"),
          );
        }

        return SizedBox.shrink();
      }

      return Scaffold(
          appBar: AppBar(
            leading: BackButton(color: Colors.white),
            title: Text(AppLocalizations.of(context)!.barcode_page_barcode),
            centerTitle: true,
          ),
          backgroundColor: Colors.black,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
                child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor,
                      accentColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "5kmrun",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        userName!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        userStatus,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 24),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: BarCodeImage(
                            params: Code39BarCodeParams(
                          formatBarcode(userId),
                          lineWidth: 1.5,
                          barHeight: 60.0,
                          withText: false,
                        )),
                      ),
                      SizedBox(height: 8),
                      Text(
                        userId.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 24),
                      buildButton(),
                    ],
                  ),
                ),
              ),
            )),
          ));
    });
  }

  String formatBarcode(int? userId) => userId.toString().padLeft(10, '0');
}
