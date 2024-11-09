import 'package:fivekmrun_flutter/common/date_extensions.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';

int getSundaysCountInYear(int year) {
  var date = DateTime(year, 1, 1).nextSunday();

  var sundays = 0;
  while (date.year == year) {
    sundays++;
    date = date.add(Duration(days: 7));
  }

  return sundays;
}

int getSaturdaysCountInYear(int year) {
  var date = DateTime(year, 12, 31).lastSaturday();

  var sundays = 0;
  while (date.year == year) {
    sundays++;
    date = date.subtract(Duration(days: 7));
  }

  return sundays;
}

bool hasMaxBadge(List<Run>? runs) {
  if (runs == null) {
    return false;
  }

  print("MAX BADGE");

  var yearsWon = <int>[];
  var officialRunsDates = runs
      .where((run) => run.date != null && !run.isSelfie)
      .map((e) => e.date!);

  var yearsToCheck = officialRunsDates.map((date) => date.year).toSet();
  yearsToCheck.remove(DateTime.now().year);

  for (var year in yearsToCheck) {
    var expectedRunsCount = getSaturdaysCountInYear(year);
    var actualRunsCount =
        officialRunsDates.where((date) => date.year == year).length;

    print("$year expectedRunsCount: $expectedRunsCount");
    print("$year actualRunsCount: $actualRunsCount");

    if (actualRunsCount >= expectedRunsCount) {
      yearsWon.add(year);
    }
  }

  print(yearsWon);
  return yearsWon.length > 0;
}

bool hasSelfieBadge(List<Run>? runs) {
  if (runs == null) {
    return false;
  }

  print("SELFIE BADGE");

  var yearsWon = <int>[];
  var selfieRunDates = runs
      .where((run) => run.date != null && run.isSelfie)
      .map((e) => e.date!.nextSunday());

  var yearsToCheck = selfieRunDates.map((date) => date.year).toSet();
  yearsToCheck.remove(DateTime.now().year);

  for (var year in yearsToCheck) {
    var expectedRunsCount = getSundaysCountInYear(year);
    var actualRunsCount =
        selfieRunDates.where((date) => date.year == year).length;

    print("$year expectedRunsCount: $expectedRunsCount");
    print("$year actualRunsCount: $actualRunsCount");

    if (actualRunsCount >= expectedRunsCount) {
      yearsWon.add(year);
    }
  }

  print(yearsWon);
  return yearsWon.length > 0;
}
