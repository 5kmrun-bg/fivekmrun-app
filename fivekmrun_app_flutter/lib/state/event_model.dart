class Event {
  final int id;
  final String title;
  final DateTime date;
  final String time;
  final String imageUrl;
  final String location;
  final String detailsUrl;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.imageUrl,
    required this.location,
    required this.detailsUrl,
  });

  Event.fromJson(dynamic json)
      : id = json["e_id"],
        title = json["e_title"],
        date = DateTime.fromMillisecondsSinceEpoch(json["e_date"] * 1000),
        time = json["e_time"],
        location = json["n_name"],
        detailsUrl = "",
        imageUrl = json["e_sponsor"];

  Event.fromXLJson(d):
      id = d["e_id"],
      title = d["n_name"],
      date = DateTime.fromMillisecondsSinceEpoch(d["e_date"] * 1000),
      time = d["e_time"],
      imageUrl = "https://firebasestorage.googleapis.com/v0/b/kmrunbg.appspot.com/o/xl-run-thumbnail-bw.png?alt=media&token=bdccfa3c-9a5a-4792-bb04-bafaaad6442a",
      location = "XLkm Run София",
      detailsUrl = " ";

  Event.fromKidsJson(d):
      id = d["e_id"],
      title = d["e_title"],
      date = DateTime.fromMillisecondsSinceEpoch(d["e_date"] * 1000),
      time = d["e_time"],
      imageUrl = "https://firebasestorage.googleapis.com/v0/b/kmrunbg.appspot.com/o/kids-run-bw.png?alt=media&token=a782fe29-6422-4b61-95b1-c4e7f81ddd5c",
      location = d["n_name"],
      detailsUrl = " ";


  static List<Event> listFromJson(dynamic json) {
    List<dynamic> events = json;
    List<Event> result = events.map((d) => Event.fromJson(d)).toList();

    return result;
  }

  static List<Event> listFromXLJson(dynamic json) {
    List<dynamic> events = json;
    List<Event> result = events.map((d) => Event.fromXLJson(d)).toList();

    return result;
  }

  static List<Event> listFromKidsJson(dynamic json) {
    List<dynamic> events = json;
    List<Event> result = events.map((d) => Event.fromKidsJson(d)).toList();

    return result;
  }
}