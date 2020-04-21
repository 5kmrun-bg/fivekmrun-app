import 'package:fivekmrun_flutter/common/milestone_gauge.dart';
import 'package:flutter/material.dart';

class MilestoneTile extends StatelessWidget {
  final int value;
  final int milestone;
  final String title;
  const MilestoneTile({Key key, this.value, this.milestone, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        MilestoneGauge(value, milestone),
        Positioned(
          bottom: 0,
          child: Text(
            title,
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}
