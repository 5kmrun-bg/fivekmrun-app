import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:intl/intl.dart';

final DateFormat dateFromat = DateFormat(Constants.DATE_FORMAT);

class RunSimple {
  final int id;
  final DateTime date;
  final int timeInSeconds;
  final String time;
  final String pace;


  String get displayDate => dateFromat.format(date);

  RunSimple(
      {this.id,
      this.date,
      this.time,
      this.timeInSeconds,
      this.pace});

  RunSimple.fromJson(dynamic json)
      : id = json["s_id"],
        date = DateTime.parse(json["s_cr_date"]),
        time = timeInSecondsToString(json["s_time"]),
        timeInSeconds = json["s_time"],
        pace = timeInSecondsToPace(json["s_time"]);

  static List<RunSimple> listFromJson(Map<String, dynamic> json) {
    List<dynamic> runs = json["runs"];
    var result = runs.map((d) => RunSimple.fromJson(d)).toList();
    return result;
  }

  static String timeInSecondsToString(int timeInSeconds, {bool sign = false}) {
    String signString = "";
    if (sign) {
      signString = timeInSeconds < 0 ? "-" : "+";
      timeInSeconds = timeInSeconds < 0 ? -timeInSeconds : timeInSeconds;
    }

    return signString +
        (timeInSeconds ~/ 60).toString().padLeft(2, '0') +
        ":" +
        (timeInSeconds % 60).toString().padLeft(2, '0');
  }

  static String timeInSecondsToSpeed(int timeInSeconds) {
    return ((5000 / timeInSeconds) * 3.6).toStringAsFixed(2);
  }

  static String timeInSecondsToPace(int timeInSeconds) {
    if (timeInSeconds == 0) {
      return "";
    }
    double paceDouble = (timeInSeconds ?? 0) / 5.0;
    final duration = Duration(seconds: paceDouble.toInt());
    String pace = duration.toString().substring(2, 7);

    return pace;
  }
}
