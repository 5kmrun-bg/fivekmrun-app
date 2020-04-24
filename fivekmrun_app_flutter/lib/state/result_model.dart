import '../common/int_extensions.dart';

class Result {
  final String name;
  final String time;
  final int position;
  final String totalRuns;
  final String sex;
  final int status;
  final bool isDisqualified;
  int officialPosition;

  Result(
      {this.name,
      this.time,
      this.position,
      this.totalRuns,
      this.sex,
      this.status = 0,
      this.isDisqualified = false});

  Result.fromJson(dynamic json)
      : name = json["u_name"] + " " + json["u_surname"],
        time = (json["s_time"] as int).parseSecondsToTimestamp(),
        position = json["s_finish_pos"],
        totalRuns = "",
        sex = json["u_sex"],
        status = json["s_type"],
        isDisqualified = json["s_type"] > 3;

  static List<Result> listFromJson(Map<String, dynamic> json) {
    List<dynamic> runs = json["runners"];
    var result = runs.map((d) => Result.fromJson(d)).toList();
    return result;
  }
}
