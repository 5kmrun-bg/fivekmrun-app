import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/custom_icons.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:provider/provider.dart';

class ResultsList extends StatefulWidget {
  final List<Result> results;

  ResultsList({Key? key, required this.results}) : super(key: key);

  @override
  _ResultsListState createState() => _ResultsListState();
}

class _ResultsListState extends State<ResultsList> {
  TextEditingController? _controller;
  ItemScrollController _scrollController = ItemScrollController();
  List<Result>? _filteredResults;
  int _userRunIndex = -1;
  int? _userId;
  bool _showScrollBtn = false;

  void initState() {
    super.initState();
    _userId =
        Provider.of<AuthenticationResource>(context, listen: false).getUserId();
    _showScrollBtn = widget.results.any((r) => r.userId == _userId);
    _filteredResults = widget.results;
    _controller = TextEditingController();
    _controller?.addListener(() {
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
          .where((res) =>
              res.name
                  .toLowerCase()
                  .contains(_controller?.text.toLowerCase() ?? "") ||
              res.userId.toString() == (_controller?.text ?? "").trim())
          .toList();
      this._userRunIndex =
          _filteredResults!.indexWhere((r) => r.userId == this._userId);
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SearchBox(
          controller: _controller!,
          showLoacateButton: this._showScrollBtn,
          locateCB: _userRunIndex >= 0 ? _scrollToView : null,
        ),
        Expanded(
          child: (_filteredResults?.length ?? 0) > 0
              ? ScrollablePositionedList.builder(
                  itemScrollController: _scrollController,
                  itemCount: _filteredResults?.length,
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
    final res = _filteredResults![index];
    final theme = Theme.of(context);

    var position = res.position.toString();
    if (res.officialPosition != 0) {
      position = res.officialPosition.toString();
    }

    final iconColor =
        res.isDisqualified ? theme.disabledColor : theme.accentColor;

    Color cardColor;

    switch (res.status) {
      case 1:
        cardColor = Colors.greenAccent;
        break;
      case 2:
        cardColor = Colors.blueAccent;
        break;
      case 3:
        cardColor = Colors.redAccent;
        break;
      case 4:
        cardColor = Colors.purpleAccent;
        break;
      case 5:
        cardColor = Colors.yellowAccent;
        break;
      default:
        cardColor = Colors.white;
    }

    Color shirtColor = legionerColor(iconColor, res);

    return GestureDetector(
        onTap: () {
          if (res.mapPolyline != "") {
            Navigator.of(context).pushNamed("/details", arguments: res);
          }
        },
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            // if (!res.isAnonymous && res.isPatreon)
            //   Positioned(
            //       child: Container(
            //         color: iconColor,
            //         child: Padding(
            //           padding: const EdgeInsets.only(
            //               top: 3, bottom: 3, right: 10, left: 10),
            //           child: Row(children: [
            //             Icon(CustomIcons.hand_holding_heart, size: 12),
            //           ]),
            //         ),
            //       ),
            //       top: 10,
            //       right: 5),
            Card(
              color: res.isDisqualified
                  ? Colors.grey.shade800
                  : Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        width: 10,
                        decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(5),
                                topLeft: Radius.circular(5))),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: IntrinsicWidth(
                          child: Column(
                            children: <Widget>[
                              ListTileRow(
                                icon: CustomIcons.award,
                                text: position,
                                iconColor: iconColor,
                              ),
                              ListTileRow(
                                icon: Icons.timer,
                                text: res.time,
                                iconColor: iconColor,
                              ),
                              if (res.isSelfie)
                                ListTileRow(
                                  icon: Icons.terrain,
                                  text: res.elevationGainedTotal
                                          .round()
                                          .toString() +
                                      "m",
                                  iconColor: iconColor,
                                )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ListTileRow(
                                icon: (res.legionerType > 0)
                                    ? CustomIcons.tshirt
                                    : Icons.perm_identity,
                                text: (res.isAnonymous || res.userId == null)
                                    ? " - "
                                    : res.userId.toString(),
                                iconSize: (res.legionerType > 0) ? 13 : 18,
                                iconColor: shirtColor),
                            ListTileRow(
                              icon: (res.isPatreon)
                                  ? CustomIcons.hand_holding_heart
                                  : Icons.person,
                              text: (!res.isAnonymous) ? res.name : "Анонимен",
                              iconColor: iconColor,
                            ),
                            if (res.isSelfie)
                              ListTileRow(
                                icon: Icons.location_city,
                                text: res.startLocation,
                                iconColor: iconColor,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Color legionerColor(Color defaultColor, Result res) {
    Color legionerColor = defaultColor;
    int totalRuns = int.tryParse(res.totalRuns) ?? 0;
    // print("TOTAL RUNS: " + totalRuns.toString());

    if (totalRuns >= 50 && totalRuns < 100)
      legionerColor = Color.fromRGBO(36, 132, 208, 1);
    if (totalRuns >= 100 && totalRuns < 200)
      legionerColor = Color.fromRGBO(202, 202, 202, 1);
    if (totalRuns >= 200 && totalRuns < 300)
      legionerColor = Color.fromRGBO(65, 170, 71, 1);
    if (totalRuns >= 300 && totalRuns < 400)
      legionerColor = Color.fromRGBO(129, 74, 177, 1);
    if (totalRuns >= 400 && totalRuns < 500)
      legionerColor = Color.fromRGBO(255, 22, 17, 1);
    if (totalRuns >= 500 && totalRuns < 600)
      legionerColor = Color.fromRGBO(222, 198, 62, 1);
    if (totalRuns >= 600) legionerColor = Color.fromRGBO(50, 173, 159, 1);

    // print("COLOR: " + legionerColor.toString());

    return legionerColor;
  }
}

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final bool showLoacateButton;
  final Function? locateCB;

  const SearchBox({
    Key? key,
    required this.controller,
    required this.showLoacateButton,
    required this.locateCB,
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
                    hintText: 'Търси по име или номер',
                    border: InputBorder.none),
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
                onPressed: () => locateCB!(),
              ),
          ],
        ),
      ),
    );
  }
}
