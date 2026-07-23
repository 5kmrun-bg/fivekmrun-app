import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:intl/intl.dart';

final DateFormat dateFromat = DateFormat(Constants.DATE_FORMAT);

/// Official (regular 5kmrun), selfie, and XL runs are mutually exclusive —
/// this used to be modeled as two independent bools (isSelfie, isXL), which
/// meant every consumer had to remember to exclude XL wherever it filtered
/// on "not selfie" to mean "official". An enum makes the exclusivity
/// structural instead of a convention every call site has to uphold.
enum RunType { official, selfie, xl }

class Run {
  final int id;
  final int? eventId;
  final DateTime? date;
  final int? timeInSeconds;
  final String? time;
  final String? location;
  final int? position;
  final String? speed;
  final String? notes;
  final String? pace;
  final RunType runType;
  final int? distance;
  final String? totalTime;

  // Calculated
  int? differenceFromPrevious;
  int? differenceFromBest;

  String get displayDate => dateFromat.format(date!);

  Run(
      {this.date,
      this.time,
      this.timeInSeconds,
      this.location,
      this.eventId,
      this.differenceFromPrevious,
      this.differenceFromBest,
      this.position,
      this.speed,
      this.notes,
      this.pace,
      this.runType = RunType.official,
      this.distance,
      this.totalTime})
      : id = ("$date#$time#$location").hashCode;

  Run.fromJson(dynamic json)
      : id = json["r_id"],
        eventId = json["r_eventid"],
        date = DateTime.fromMillisecondsSinceEpoch(json["e_date"] * 1000),
        time = timeInSecondsToString(json["r_time"]),
        totalTime = timeInSecondsToString(json["r_time"]),
        timeInSeconds = json["r_time"],
        location = json["n_name"],
        differenceFromBest = json[""],
        differenceFromPrevious = json[""],
        position = json["r_finish_pos"],
        speed = timeInSecondsToSpeed(json["r_time"]),
        notes = "",
        pace = timeInSecondsToPace(json["r_time"]),
        runType = RunType.official,
        distance = 5000;

  // For XLrun — same r_*/n_name shape as the regular result endpoint (see
  // Run.fromJson), but n_name carries "<place> <distance> км" instead of a
  // clean location, and the distance is never 5000m, so pace/speed need the
  // real distance parsed out of it rather than the fixed 5km assumption the
  // rest of this class makes.
  Run.fromXLJson(dynamic json)
      : id = json["r_id"],
        eventId = json["r_eventid"],
        date = DateTime.fromMillisecondsSinceEpoch(json["e_date"] * 1000),
        time = timeInSecondsToString(json["r_time"]),
        totalTime = timeInSecondsToString(json["r_time"]),
        timeInSeconds = json["r_time"],
        location = _xlLocationFromName(json["n_name"]),
        differenceFromBest = null,
        differenceFromPrevious = null,
        position = json["r_finish_pos"],
        speed = timeInSecondsToSpeed(json["r_time"],
            distanceMeters: _xlDistanceMetersFromName(json["n_name"]) ?? 5000),
        notes = "",
        pace = timeInSecondsToPace(json["r_time"],
            distanceMeters: _xlDistanceMetersFromName(json["n_name"]) ?? 5000),
        runType = RunType.xl,
        distance = _xlDistanceMetersFromName(json["n_name"]);

  static List<Run> listFromJson(Map<String, dynamic> json) {
    List<dynamic> runs = json["runners"];
    var result = List<Run>.from(runs.map((d) => Run.fromJson(d)));
    return result;
  }

  Run.fromSelfieJson(dynamic json)
      : id = json["s_id"],
        eventId = null, //json["r_eventid"],
        date = DateTime.parse(json["s_start_date"]),
        time = timeInSecondsToString(json["s_time"]),
        timeInSeconds = json["s_time"],
        location = "", //json["n_name"],
        differenceFromBest = json[""],
        differenceFromPrevious = json[""],
        position = json["s_finish_pos"],
        speed = timeInSecondsToSpeed(json["s_time"]),
        notes = "",
        pace = timeInSecondsToPace(json["s_time"]),
        runType = RunType.selfie,
        distance = json["s_total_distance"] ?? 5000,
        totalTime = timeInSecondsToString(json[
            "s_total_elapsed_time"] ?? 0); //timeInSecondsToPace(json["r_time"]);

  static List<Run> selfieListFromJson(Map<String, dynamic> json) {
    List<dynamic> runs = json["runs"];
    var result = List<Run>.from(runs.map((d) => Run.fromSelfieJson(d)));
    return result;
  }

  /// The xlrun/user/<id> endpoint carries the user's own XL results in two
  /// places — the top-level "runners" (observed to be the current year) and
  /// per-year breakdowns under "years"[].results. Which one is authoritative
  /// for older results isn't confirmed, so both are merged and de-duplicated
  /// by r_id rather than picking just one and risking missing runs.
  static List<Run> listFromXLUserJson(dynamic json) {
    final List<dynamic> current = (json["runners"] as List<dynamic>?) ?? [];
    final List<dynamic> years = (json["years"] as List<dynamic>?) ?? [];
    final List<dynamic> historic = years
        .expand((y) => (y["results"] as List<dynamic>?) ?? const [])
        .toList();

    final Map<int, dynamic> byId = {};
    for (final r in [...current, ...historic]) {
      byId[r["r_id"] as int] = r;
    }

    return byId.values.map((d) => Run.fromXLJson(d)).toList();
  }

  static final RegExp _xlNameDistancePattern =
      RegExp(r'^(.*?)\s+([\d]+(?:\.[\d]+)?)\s*км\.?$', caseSensitive: false);

  /// XLrun's n_name is "<place> <distance> км" (e.g. "Сеславци 7.6 км")
  /// instead of a clean location string — strip the distance suffix off.
  /// Falls back to the raw text if it doesn't match the expected pattern.
  static String _xlLocationFromName(String nName) {
    final match = _xlNameDistancePattern.firstMatch(nName.trim());
    return match?.group(1)?.trim() ?? nName;
  }

  /// Parses the distance embedded in XLrun's n_name text. There is no clean
  /// numeric distance field on this endpoint. Returns null if unparseable —
  /// callers fall back to the 5km assumption used everywhere else.
  static int? _xlDistanceMetersFromName(String nName) {
    final match = _xlNameDistancePattern.firstMatch(nName.trim());
    if (match == null) {
      return null;
    }

    final km = double.tryParse(match.group(2)!);
    if (km == null) {
      return null;
    }

    return (km * 1000).round();
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

  static String timeInSecondsToSpeed(int timeInSeconds,
      {int distanceMeters = 5000}) {
    if (timeInSeconds == 0) {
      return "";
    }

    return ((distanceMeters / timeInSeconds) * 3.6).toStringAsFixed(2);
  }

  static String timeInSecondsToPace(int timeInSeconds,
      {int distanceMeters = 5000}) {
    if (timeInSeconds == 0) {
      return "";
    }

    double paceDouble = timeInSeconds / (distanceMeters / 1000.0);
    final duration = Duration(seconds: paceDouble.toInt());
    String pace = duration.toString().substring(2, 7);

    return pace;
  }

  static String distanceToString(int distance) {
    return (distance / 1000).toStringAsFixed(2);
  }
}
