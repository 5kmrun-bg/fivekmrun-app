class User {
  int id;
  String name;
  String avatarUrl;
  int runsCount;
  double totalKmRan;
  int age;

  User({this.id, this.name, this.avatarUrl, this.runsCount, this.totalKmRan, this.age});

  User.fromJson(Map<String, dynamic> json) {
    List<dynamic> runs = json["runners"];
    if (runs.length > 0) {
      Map run = runs[0];
      id = run["r_uid"];
      name = run["u_name"] + " " + run["u_surname"];
      runsCount = run["u_runs"];
      // Total km is not runsCount * 5, because runsCount contains alo volunteering
      totalKmRan = runs.length * 5.0;
    } else {
      id = 13731;
      name = "fake user";
      runsCount = 33;
      totalKmRan = 33 * 5.0;
    }
  }
}
