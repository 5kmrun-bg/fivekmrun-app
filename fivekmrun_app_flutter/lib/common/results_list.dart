import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:flutter/material.dart';

class ResultsList extends StatefulWidget {
  final List<Result> results;

  ResultsList({Key key, this.results}) : super(key: key);

  @override
  _ResultsListState createState() => _ResultsListState();
}

class _ResultsListState extends State<ResultsList> {
  TextEditingController _controller;
  List<Result> _filteredResults;

  void initState() {
    super.initState();
    _filteredResults = widget.results;
    _controller = TextEditingController();
    _controller.addListener(() {
      this._doFilter();
    });
  }

  @override
  void didUpdateWidget(ResultsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (this.widget.results != oldWidget.results) {
      this._doFilter();
    }
  }

  void _doFilter() {
    setState(() {
      _filteredResults = widget.results
          .where((res) => res.name
              .toLowerCase()
              .contains(_controller.text.toLowerCase() ?? ""))
          .toList();
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SearchBox(controller: _controller),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredResults.length,
            itemBuilder: resultTileBuilder,
          ),
        ),
      ],
    );
  }

  Widget resultTileBuilder(BuildContext context, int index) {
    final res = _filteredResults[index];
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    var position = res.position.toString();
    if (res.officialPosition != null) {
      position = res.officialPosition.toString();
    }

    final positionStyle = res.isDisqualified
        ? textTheme.display2.copyWith(color: theme.disabledColor)
        : textTheme.display2.copyWith(color: theme.accentColor);
    final iconColor =
        res.isDisqualified ? theme.disabledColor : theme.accentColor;
        
    return Card(
      color: res.isDisqualified ? Colors.grey.shade800 : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 20, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    position,
                    style: positionStyle,
                  ),
                  Text("място", style: textTheme.subtitle),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTileRow(
                    icon: Icons.person,
                    text: res.name,
                    iconColor: iconColor,
                  ),
                  ListTileRow(
                    icon: Icons.timer,
                    text: res.time,
                    iconColor: iconColor,
                  ),
                  if (res.status > 0 && res.status <= 2)
                    ListTileRow(
                      icon: Icons.check_box,
                      text: "доказан",
                      iconColor: iconColor,
                    ),
                  if (res.status == 3)
                    ListTileRow(
                      icon: Icons.check,
                      text: "самостоятелен",
                      iconColor: iconColor,
                    ),
                  if (res.status > 3 && res.status <= 5)
                    ListTileRow(
                      icon: Icons.error,
                      text: "дисквалифициран",
                      iconColor: iconColor,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  const SearchBox({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Card(
        child: ListTile(
          leading: Icon(Icons.search),
          title: TextField(
            controller: controller,
            decoration: new InputDecoration(
                hintText: 'Search', border: InputBorder.none),
          ),
          trailing: new IconButton(
            icon: new Icon(Icons.cancel),
            onPressed: () {
              controller.clear();
            },
          ),
        ),
      ),
    );
  }
}
