import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:intl/intl.dart';

final DateFormat dateFromat = DateFormat(Constants.DATE_FORMAT);

class Run {
  final int id;
  final DateTime date;
  final int timeInSeconds;
  final String time;
  final String location;
  final String differenceFromPrevious;
  final String differenceFromBest;
  final int position;
  final String speed;
  final String notes;
  final String pace;

  String get displayDate => dateFromat.format(date);

  Run(
      {this.date,
      this.time,
      this.timeInSeconds,
      this.location,
      this.differenceFromPrevious,
      this.differenceFromBest,
      this.position,
      this.speed,
      this.notes,
      this.pace})
      : id = ("$date#$time#$location").hashCode;

  Run.fromJson(dynamic json) :
    id = json["r_id"],
    date = DateTime.fromMillisecondsSinceEpoch(json["e_date"] * 1000),
    time = timeInSecondsToString(json["r_time"]),
    timeInSeconds = json["r_time"],
    location = json["n_name"],
    differenceFromBest = "",
    differenceFromPrevious = "",
    position = json["r_finish_pos"],
    speed = "",
    notes = "",
    pace = "";
  
  static List<Run> listFromJson(Map<String, dynamic> json) {
    List<dynamic> runs = json["runners"];
    var result = runs.map((d) => Run.fromJson(d)).toList();
    return result;
  }

  static String timeInSecondsToString(int timeInSeconds) {
    return (timeInSeconds ~/ 60).toString().padLeft(2, '0') + ":" + (timeInSeconds % 60).toString().padLeft(2, '0');
  }
}