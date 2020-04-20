import 'package:fivekmrun_flutter/common/results_list.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:fivekmrun_flutter/state/results_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OfflineChartPage extends StatefulWidget {
  OfflineChartPage({Key key}) : super(key: key);

  @override
  _OfflineChartPageState createState() => _OfflineChartPageState();
}

class _OfflineChartPageState extends State<OfflineChartPage> {
  bool thisWeekSelected = true;
  List<Result> results;
  ResultsResource lastWeekResource = ResultsResource();
  ResultsResource thisWeekResource = ResultsResource();

  selectThisWeek() {
    if (this.thisWeekSelected) {
      return;
    }
    setState(() {
      this.thisWeekSelected = true;
    });

    this._loadFakeThistWeekResult();
  }

  selectLastWeek() {
    if (!this.thisWeekSelected) {
      return;
    }

    setState(() {
      this.thisWeekSelected = false;
    });

    this._loadFakeLastWeekResult();
  }

  void goToAddEntry() {
    final authResource =
        Provider.of<AuthenticationResource>(context, listen: false);

    if (authResource.isLoggedIn()) {
      Navigator.of(context).pushNamed("/add");
    } else {
      this.showLogoutDialog();
    }
  }

  void showLogoutDialog() {
    final userResource = Provider.of<UserResource>(context, listen: false);
    final textStlyle = Theme.of(context).textTheme.subtitle;
    final accentColor = Theme.of(context).accentColor;
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Вход с парола"),
          content: RichText(
            text: TextSpan(
              style: textStlyle,
              children: <TextSpan>[
                TextSpan(text: 'Участието в '),
                TextSpan(
                  text: 'Selfie',
                  style: textStlyle.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: ' класацията е достъпно вход с парола!'),
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("вход с парола"),
              onPressed: () {
                userResource.currentUserId = null;
                userResource.value = null;
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil("/", (_) => false);
              },
            ),
            new FlatButton(
              child: new Text("откажи"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    this._loadFakeThistWeekResult();
  }

  _loadFakeLastWeekResult() {
    setState(() {
      this.results = null;
      this.lastWeekResource.load(id: 1537).then((loadedResults) {
        this.setState(() => this.results = loadedResults);
      });
    });
  }

  _loadFakeThistWeekResult() {
    setState(() {
      this.results = null;
      this.thisWeekResource.load(id: 1525).then((loadedResults) {
        this.setState(() => this.results = loadedResults);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Седмична офлайн класация'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SelectButton(
                  text: "Предходна седмица",
                  onPressed: this.selectLastWeek,
                  selected: !this.thisWeekSelected,
                ),
                SelectButton(
                  text: "Текуща седмица",
                  onPressed: this.selectThisWeek,
                  selected: this.thisWeekSelected,
                ),
              ],
            ),
            Expanded(child: this._buildResults()),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      onPressed: () => this.goToAddEntry(),
                      child: Text("Участвай в класацията"),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (this.results == null) {
      return Center(child: CircularProgressIndicator());
    } else if (this.results.length == 0) {
      return Center(child: Text("Няма резултати"));
    } else {
      return ResultsList(results: this.results);
    }
  }
}

class SelectButton extends StatelessWidget {
  final Function onPressed;
  final bool selected;
  final String text;

  const SelectButton({Key key, this.onPressed, this.selected, this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: this.selected
            ? RaisedButton(
                child: Text(this.text, style: Theme.of(context).textTheme.subhead),
                onPressed: this.onPressed,
              )
            : OutlineButton(
                child: Text(this.text, style: Theme.of(context).textTheme.subhead),
                onPressed: this.onPressed,
              ),
      ),
    );
  }
}
