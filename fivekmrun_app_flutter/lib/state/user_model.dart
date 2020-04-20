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
      // TODO: This number doesn't include volunteering currently
      runsCount = run["u_runs"];
      avatarUrl = run["pic"];
      // Total km is not runsCount * 5, because runsCount contains alo volunteering
      totalKmRan = runs.length * 5.0;
      age = calculateAge(DateTime.fromMillisecondsSinceEpoch(run["u_bdate"] * 1000));
    } else {
      id = 13731;
      name = "fake user";
      runsCount = 33;
      totalKmRan = 33 * 5.0;
    }
  }

  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }
}
