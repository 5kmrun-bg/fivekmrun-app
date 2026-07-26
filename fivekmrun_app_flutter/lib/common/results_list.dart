import 'package:fivekmrun_flutter/common/legioner_status_helper.dart';
import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/custom_icons.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


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
                  itemCount: _filteredResults?.length ?? 0,
                  itemBuilder: resultTileBuilder,
                )
              : Center(
                  child: Text(AppLocalizations.of(context)!.results_list_no_results),
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
        res.isDisqualified ? theme.disabledColor : theme.colorScheme.secondary;

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

    Color shirtColor = LegionerStatusHelper.getLegionerColor(
        iconColor, int.tryParse(res.totalRuns) ?? 0);

    return GestureDetector(
        onTap: () {
          if (res.mapPolyline != "") {
            Navigator.of(context).pushNamed("/details", arguments: res);
          }
        },
        child: Stack(
          alignment: Alignment.topRight,
          children: [
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
                                icon: (res.isLegioner)
                                    ? CustomIcons.tshirt
                                    : Icons.perm_identity,
                                text: (res.isAnonymous)
                                    ? " - "
                                    : res.userId.toString(),
                                iconSize: (res.isLegioner) ? 13 : 18,
                                iconColor: shirtColor),
                            ListTileRow(
                              icon: (res.isPatreon)
                                  ? CustomIcons.hand_holding_heart
                                  : Icons.person,
                              text: (!res.isAnonymous) ? res.name : AppLocalizations.of(context)!.results_list_anonymous,
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
                    hintText: AppLocalizations.of(context)!.results_list_search_bar,
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
