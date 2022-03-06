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
  final bool isPatreon;
  final int legionerType;
  final bool isAnonymous;
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
  DateTime? startDate;
  final String? stravaLink;

  Result(
      {required this.name,
      required this.time,
      required this.position,
      required this.totalRuns,
      required this.sex,
      this.status = 0,
      this.isDisqualified = false,
      this.userId = -1,
      this.isSelfie = false,
      this.isPatreon = false,
      this.legionerType = 0,
      this.isAnonymous = false,
      this.totalDistance = 0,
      this.distance = 0,
      this.totalTime = "",
      this.pace = "",
      this.elevationGainedTotal = 0,
      this.elevationHigh = 0,
      this.elevationLow = 0,
      this.mapPolyline = "",
      this.officialPosition = 0,
      this.startDate,
      this.startLocation = " - ",
      this.stravaLink});

  // For Selfie
  Result.fromJson(dynamic json)
      : name = json["u_name"] + " " + json["u_surname"],
        userId = json["s_uid"],
        time = (json["s_time"] as int).parseSecondsToTimestamp(),
        totalTime = _getNonZeroTime(json, "s_total_elapsed_time"),
        position = json["s_finish_pos"],
        totalRuns = json["u_runs_s"].toString(),
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
        isSelfie = true,
        isAnonymous = false,
        isPatreon = checkPatreonship(json),
        legionerType = Result.getSelfieLegionerType(json),
        officialPosition = 0,
        stravaLink = json["s_strava_link"];

  static bool checkPatreonship(json) {
    return json["p_id"] != null ||
        (json["u_daritel"] ?? 0) * 1000 >=
            DateTime.now().millisecondsSinceEpoch;
  }

  static List<Result> listFromJson(Map<String, dynamic> json) {
    List<dynamic> runs = json["runners"];
    var result = runs.map((d) => Result.fromJson(d)).toList();
    return result;
  }

  // For official
  Result.fromEventJson(dynamic json)
      : name = json["u_name"] + " " + json["u_surname"],
        userId = json["r_uid"],
        time = (json["r_time"] as int).parseSecondsToTimestamp(),
        position = json["r_finish_pos"],
        totalRuns = "",
        sex = json["u_sex"],
        status = 0, //json["s_type"],
        isDisqualified = false, //json["s_type"] > 3,
        pace = Run.timeInSecondsToPace(json["r_time"] as int),
        isSelfie = false,
        isPatreon = json["p_id"] != null,
        legionerType = Result.getLegionerType(json),
        isAnonymous = json["r_uid"] == 0,
        mapPolyline = "",
        elevationLow = 0,
        elevationHigh = 0,
        elevationGainedTotal = 0,
        officialPosition = 0,
        startLocation = "",
        startDate = null,
        totalDistance = 0,
        distance = 0,
        totalTime = "",
        stravaLink = null;

  static int getLegionerType(dynamic json) {
    var totalRuns = ((json["r_runs"] ?? 0) + (json["u_help"] ?? 0));
    return totalRunsToEnum(totalRuns);
  }

  static int getSelfieLegionerType(dynamic json) {
    var totalRuns = json["u_runs_s"];
    return totalRunsToEnum(totalRuns);
  }

  static int totalRunsToEnum(int totalRuns) {
    if (totalRuns < 50) return 0;
    if (totalRuns >= 50 && totalRuns < 100) return 1;
    if (totalRuns >= 100 && totalRuns < 250) return 2;
    if (totalRuns >= 250) return 3;

    return 0;
  }

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
