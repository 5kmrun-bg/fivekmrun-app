import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:provider/provider.dart';

class ResultsList extends StatefulWidget {
  final List<Result> results;

  ResultsList({Key key, this.results}) : super(key: key);

  @override
  _ResultsListState createState() => _ResultsListState();
}

class _ResultsListState extends State<ResultsList> {
  TextEditingController _controller;
  ItemScrollController _scrollController = ItemScrollController();
  List<Result> _filteredResults;
  int _userRunIndex = -1;
  int _userId;
  bool _showScrollBtn = false;

  void initState() {
    super.initState();
    _userId =
        Provider.of<AuthenticationResource>(context, listen: false).getUserId();
    _showScrollBtn = widget.results.any((r) => r.userId == _userId);
    _filteredResults = widget.results;
    _controller = TextEditingController();
    _controller.addListener(() {
      this._doFilter();
    });
    this._doFilter();
    // print("Results.initState $_userId $_showScrollBtn $_userRunIndex");
  }

  @override
  void didUpdateWidget(ResultsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // print("Results.didUpdateWidget $_userId $_showScrollBtn $_userRunIndex");

    _userId =
        Provider.of<AuthenticationResource>(context, listen: false).getUserId();
    _showScrollBtn = widget.results.any((r) => r.userId == _userId);

    if (this.widget.results != oldWidget.results) {
      this._doFilter();
    }
  }

  void _scrollToView() {
    this._scrollController.scrollTo(
          index: this._userRunIndex,
          duration: Duration(seconds: 1),
        );
  }

  void _doFilter() {
    setState(() {
      _filteredResults = widget.results
          .where((res) => res.name
              .toLowerCase()
              .contains(_controller.text.toLowerCase() ?? ""))
          .toList();
      this._userRunIndex =
          _filteredResults.indexWhere((r) => r.userId == this._userId);
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
        SearchBox(
          controller: _controller,
          showLoacateButton: this._showScrollBtn,
          locateCB: _userRunIndex >= 0 ? _scrollToView : null,
        ),
        Expanded(
          child: _filteredResults.length > 0
              ? ScrollablePositionedList.builder(
                  itemScrollController: _scrollController,
                  itemCount: _filteredResults.length,
                  itemBuilder: resultTileBuilder,
                )
              : Center(
                  child: Text("Няма резултати"),
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
  final bool showLoacateButton;
  final Function locateCB;

  const SearchBox({
    Key key,
    this.controller,
    this.showLoacateButton,
    this.locateCB,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Card(
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.search),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: new InputDecoration(
                    hintText: 'Търси', border: InputBorder.none),
              ),
            ),
            IconButton(
              icon: new Icon(Icons.cancel),
              onPressed: () {
                controller.clear();
              },
            ),
            if (showLoacateButton)
              new IconButton(
                icon: new Icon(Icons.location_searching),
                onPressed: locateCB,
              ),
          ],
        ),
      ),
    );
  }
}
