class User {
  int id;
  String name;
  String avatarUrl;
  int age;
  int donationsCount;

  User({this.id, this.name, this.avatarUrl, this.age, this.donationsCount});

  User.fromJson(int userId, Map<String, dynamic> json) {
    final user = json["user"][0];
    if (user != null) {
      id = userId;
      name = user["u_name"] + " " + user["u_surname"];
      avatarUrl = user["pic"];
      donationsCount = user["u_sponsor"] ?? 0;
      print("Has donated: " + donationsCount.toString());
      age = calculateAge(DateTime.fromMillisecondsSinceEpoch(user["u_bdate"] * 1000));
    } else {
      id = 0;
      name = "fake user";
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
