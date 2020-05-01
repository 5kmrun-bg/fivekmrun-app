import 'package:fivekmrun_flutter/state/strava_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StravaConnect extends StatefulWidget {
  StravaConnect({Key key}) : super(key: key);

  @override
  _StravaConnectState createState() => _StravaConnectState();
}

class _StravaConnectState extends State<StravaConnect> {
  bool isLoading = true;
  bool isConnectedToStrava = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    final strava = Provider.of<StravaResource>(this.context, listen: false);
    final isConnectedToStrava = await strava.isAuthenticated();

    setState(() {
      this.isLoading = false;
      this.isConnectedToStrava = isConnectedToStrava;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strava = Provider.of<StravaResource>(this.context, listen: false);

    void connect() async {
      if (this.isLoading) {
        return;
      }
      this.setState(() => this.isLoading = true);

      final result = await strava.authenticate();

      this.setState(() {
        this.isLoading = false;
        this.isConnectedToStrava = result;
      });
    }

    void disconnect() async {
      if (this.isLoading) {
        return;
      }

      this.setState(() => this.isLoading = true);

      await strava.deAuthenticate();

      this.setState(() {
        this.isLoading = false;
        this.isConnectedToStrava = false;
      });
    }

    return Container(
      child: this.isLoading
          ? CircularProgressIndicator()
          : this.isConnectedToStrava
              ? RaisedButton(
                  child: Text("disconnect"),
                  onPressed: disconnect,
                )
              : RaisedButton(
                  child: Text("connect"),
                  onPressed: connect,
                ),
    );
  }
}
