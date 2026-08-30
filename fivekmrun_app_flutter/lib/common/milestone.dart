import 'package:fivekmrun_flutter/common/legioner_status_helper.dart';
import 'package:fivekmrun_flutter/common/milestone_gauge.dart';
import 'package:flutter/material.dart';

class MilestoneTile extends StatelessWidget {
  final int value;
  final int milestone;
  final String title;
  const MilestoneTile(
      {super.key,
      required this.value,
      required this.milestone,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        MilestoneGauge(
            value,
            milestone,
            LegionerStatusHelper.getLegionerColor(
                Theme.of(context).colorScheme.secondary, value)),
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
