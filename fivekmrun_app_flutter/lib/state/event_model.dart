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

  static List<Event> listFromJson(dynamic json) {
    List<dynamic> events = json;
    List<Event> result = events.map((d) => Event.fromJson(d)).toList();

    return result;
  }
}
