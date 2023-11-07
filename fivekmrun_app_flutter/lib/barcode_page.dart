import 'dart:io';

import 'package:barcode_widgets/barcode_flutter.dart';
import 'package:add_to_google_wallet/widgets/add_to_google_wallet_button.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class BarcodePage extends StatelessWidget {
  
  final Uuid uuid = Uuid();
  final issuerId = '';
  final classId = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<UserResource>(builder: (context, userResource, child) {
      final user = userResource.value;
      final userId = (user?.id != null) ? user?.id : 0;
      final userName = (user?.name != null) ? user?.name : "";

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
                "cardTitle": {
                  "defaultValue": {
                    "language": "en-US",
                    "value": "5kmrun"
                  }
                },
                "subheader": {
                  "defaultValue": {
                    "language": "en-US",
                    "value": "Бегач"
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
                  "value": "$userId",
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
          );
        }
        
        return SizedBox.shrink();
      }

      return Scaffold(
          appBar: AppBar(
            leading: BackButton(color: Colors.white),
            title: Text("Баркод"),
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(children: <Widget>[
                Text(userName!, style: TextStyle(color: Colors.black)),
                BarCodeImage(
                  params: Code39BarCodeParams(
                    userId.toString().padLeft(10, '0'),
                    lineWidth: 2.0, // width for a single black/white bar (default: 2.0)
                    barHeight: 90.0, // height for the entire widget (default: 100.0)
                    withText: false,
                  )
                ),
                Text(userId.toString(), style: TextStyle(color: Colors.black)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: buildButton()
                    )
                  )
                )
              ]
            )
          ),
        ));
    });
  }
}
