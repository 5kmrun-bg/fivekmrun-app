import 'package:fivekmrun_flutter/common/results_list.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:fivekmrun_flutter/state/results_resource.dart';
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
                  text: "Милата седмица",
                  onPressed: this.selectLastWeek,
                  selected: !this.thisWeekSelected,
                ),
                SelectButton(
                  text: "Тази седмица",
                  onPressed: this.selectThisWeek,
                  selected: this.thisWeekSelected,
                ),
              ],
            ),
            Expanded(child: this._buildResults(context)),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      onPressed: () => Navigator.of(context).pushNamed("/add"),
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

  Widget _buildResults(BuildContext context) {
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
                child: Text(this.text),
                onPressed: this.onPressed,
              )
            : OutlineButton(
                child: Text(this.text),
                onPressed: this.onPressed,
              ),
      ),
    );
  }
}
