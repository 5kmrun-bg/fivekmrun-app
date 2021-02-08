import 'package:fivekmrun_flutter/state/run_model.dart';

import '../common/int_extensions.dart';

class Result {
  final String name;
  final int userId;
  final String time;
  final int position;
  final String totalRuns;
  final String sex;
  final int status;
  final bool isDisqualified;
  final bool isSelfie;
  int officialPosition;
  String startLocation;
  double elevationLow;
  double elevationHigh;
  double elevationGainedTotal;
  String mapPolyline;
  int distance;
  int totalDistance;
  String totalTime;
  String pace;
  DateTime startDate;

  Result(
      {this.name,
      this.time,
      this.position,
      this.totalRuns,
      this.sex,
      this.status = 0,
      this.isDisqualified = false,
      this.userId = -1,
      this.isSelfie = false});

  Result.fromJson(dynamic json)
      : name = json["u_name"] + " " + json["u_surname"],
        userId = json["s_uid"],
        time = (json["s_time"] as int).parseSecondsToTimestamp(),
        totalTime = _getNonZeroTime(json, "s_total_elapsed_time"),
        position = json["s_finish_pos"],
        totalRuns = "",
        sex = json["u_sex"],
        status = json["s_type"],
        isDisqualified = json["s_type"] > 3,
        startLocation = json["s_start_location"],
        elevationLow = _jsonToDouble(json["s_elevation_loss"]),
        elevationHigh = _jsonToDouble(json["s_elevation_gained"]),
        elevationGainedTotal = _jsonToDouble(json["s_elevation_gained_total"]),
        mapPolyline = json["s_map"],
        distance = json["s_distance"],
        totalDistance = json["s_total_distance"],
        pace = Run.timeInSecondsToPace(json["s_time"] as int),
        startDate = DateTime.parse(json["s_start_date"]),
        isSelfie = true;

  static List<Result> listFromJson(Map<String, dynamic> json) {
    List<dynamic> runs = json["runners"];
    var result = runs.map((d) => Result.fromJson(d)).toList();
    return result;
  }

  Result.fromEventJson(dynamic json)
      : name = json["u_name"] + " " + json["u_surname"],
        userId = json["r_uid"],
        time = (json["r_time"] as int).parseSecondsToTimestamp(),
        position = json["r_finish_pos"],
        totalRuns = "",
        sex = json["u_sex"],
        status = 0,//json["s_type"],
        isDisqualified = false,//json["s_type"] > 3,
        pace = Run.timeInSecondsToPace(json["r_time"] as int),
        isSelfie = false;

  static List<Result> listFromEventJson(List<dynamic> runs) {
    var result = runs.map((d) => Result.fromEventJson(d)).toList();
    return result;
  }

  static double _jsonToDouble(dynamic value) {
    if (value == null || value == 0) {
      return 0.0;
    }

    return value * 1.0;
  }

  static String _getNonZeroTime(dynamic json, String prop) {
    if (json[prop] != null && (json[prop] as int) > 0) {
      return (json[prop] as int).parseSecondsToTimestamp();
    } else {
      return "";
    }
  }
}
