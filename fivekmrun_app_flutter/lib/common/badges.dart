import 'package:collection/collection.dart';
import 'package:fivekmrun_flutter/common/date_extensions.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';

bool _hasBadge(List<Run>? runs, bool Function(Run run, DateTime date)) {
  var hasBadge = false;
  if (runs == null) {
    return hasBadge;
  }

  var now = DateTime.now();
  var runsByYear = groupBy(runs, (Run run) => run.date?.year);

  for (var i = 0; i < runsByYear.length; i++) {
    DateTime lastSaturday;
    var year = runsByYear.keys.elementAt(i);
    if (year == now.year) {
      lastSaturday = now.lastSaturday();
    } else {
      lastSaturday = DateTime(year as int, 12, 31).lastSaturday();
    }

    var hasBadgeThisYear = true;
    var saturday = lastSaturday;
    while (saturday.year == year) {
      var participated =
          runs.firstWhereOrNull((run) => Function(run, saturday));
      if (participated == null) {
        hasBadgeThisYear = false;
        break;
      }
      saturday = saturday.subtract(Duration(days: 7));
    }

    if (hasBadgeThisYear) {
      hasBadge = true;
      break;
    }
  }

  return hasBadge;
}

bool hasMaxBadge(List<Run>? runs) {
  return _hasBadge(
      runs,
      (run, date) =>
          run.date != null &&
          !run.isSelfie &&
          DateUtils.isSameDay(date, run.date as DateTime));
}

bool hasSelfieBadge(List<Run>? runs) {
  return _hasBadge(
      runs,
      (run, date) =>
          run.date != null &&
          run.isSelfie &&
          DateUtils.isSameDay(date, run.date as DateTime));
}
