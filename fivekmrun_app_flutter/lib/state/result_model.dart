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
  int officialPosition;
  String startLocation;
  double elevationLow;
  double elevationHigh;
  double elevationGainedTotal;
  String mapPolyline;
  int distance;
  String pace;

  Result(
      {this.name,
      this.time,
      this.position,
      this.totalRuns,
      this.sex,
      this.status = 0,
      this.isDisqualified = false,
      this.userId = -1});

  Result.fromJson(dynamic json)
      : name = json["u_name"] + " " + json["u_surname"],
        userId = json["s_uid"],
        time = (json["s_time"] as int).parseSecondsToTimestamp(),
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
        pace = Run.timeInSecondsToPace(json["s_time"] as int);

  static List<Result> listFromJson(Map<String, dynamic> json) {
    List<dynamic> runs = json["runners"];
    var result = runs.map((d) => Result.fromJson(d)).toList();
    return result;
  }

  static double _jsonToDouble(dynamic value) {
    if (value == null || value == 0) {
      return 0.0;
    }
    
    return value * 1.0;
  }
}
