import 'package:fivekmrun_flutter/state/strava_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StravaConnect extends StatefulWidget {
  StravaConnect({Key? key}) : super(key: key);

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

    // The State can be torn down while the call above is in flight — backing
    // out of Settings mid-check is an ordinary action, and the real resource
    // talks to an OAuth client, so the window is wide.
    if (!mounted) return;

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

      if (!mounted) return;

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

      // Awaited so the button doesn't flip to "connect" before the
      // deauthorization has actually completed — and so a failure surfaces
      // here rather than as an unhandled async error.
      await strava.deAuthenticate();

      if (!mounted) return;

      this.setState(() {
        this.isLoading = false;
        this.isConnectedToStrava = false;
      });
    }

    return Container(
      child: this.isLoading
          ? CircularProgressIndicator()
          : this.isConnectedToStrava
              ? ElevatedButton(
                  child: Text("disconnect"),
                  onPressed: disconnect,
                )
              : ElevatedButton(
                  child: Text("connect"),
                  onPressed: connect,
                ),
    );
  }
}
