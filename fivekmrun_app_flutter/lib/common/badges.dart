import 'package:collection/collection.dart';
import 'package:fivekmrun_flutter/common/date_extensions.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';

bool _hasBadge(List<Run>? runs, bool Function(Run run, DateTime date)) {
  if (runs == null) {
    return false;
  }

  DateTime now = DateTime.now();
  DateTime lastSaturday = now.lastSaturday();

  DateTime saturday = lastSaturday;
  while (saturday.year == now.year) {
    saturday = saturday.subtract(Duration(days: 7));
    Run? participated = runs.firstWhereOrNull((run) => Function(run, saturday));
    if (participated == null) {
      return false;
    }
  }

  return true;
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
