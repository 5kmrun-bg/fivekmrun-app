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

  // The XLrun endpoint returns one row per distance tier for a given
  // day/location (short/medium/XL), sharing e_num + e_date. Group those rows
  // into a single XLEvent per day/location instead of one card per distance.
  static List<Event> listFromXLJson(dynamic json) {
    List<dynamic> rows = json;
    final Map<String, List<dynamic>> groups = {};

    for (final row in rows) {
      // Fall back to e_id when e_num is missing so unrelated rows don't
      // collapse into a single group.
      final key = "${row["e_num"] ?? row["e_id"]}_${row["e_date"]}";
      groups.putIfAbsent(key, () => []).add(row);
    }

    return groups.values.map((rows) => XLEvent.fromRows(rows)).toList();
  }

  static List<Event> listFromKidsJson(dynamic json) {
    List<dynamic> events = json;
    List<Event> result = events.map((d) => Event.fromKidsJson(d)).toList();

    return result;
  }
}

/// A grouped XLrun event: one card per day/location, carrying every
/// distance tier offered that day (e.g. "4.8 km · 9.6 km · 14.4 km").
class XLEvent extends Event {
  final List<String> distances;

  XLEvent({
    required super.id,
    required super.title,
    required super.date,
    required super.time,
    required super.imageUrl,
    required super.location,
    required super.detailsUrl,
    required this.distances,
  });

  static const String _thumbnailUrl =
      "https://firebasestorage.googleapis.com/v0/b/kmrunbg.appspot.com/o/xl-run-thumbnail-bw.png?alt=media&token=bdccfa3c-9a5a-4792-bb04-bafaaad6442a";

  // n_name is "<place name> <distance> км", e.g. "с. Кътина 4.8 км".
  static final RegExp _distanceSuffix =
      RegExp(r'\s+[\d.,]+\s*км\.?\s*$', caseSensitive: false);
  static final RegExp _distanceValue =
      RegExp(r'([\d.,]+)\s*км', caseSensitive: false);

  factory XLEvent.fromRows(List<dynamic> rows) {
    final first = rows.first;
    final String rawName = first["n_name"] ?? "";
    final String location = rawName.replaceAll(_distanceSuffix, "").trim();

    final List<String> distances = rows.map<String>((row) {
      final String name = row["n_name"] ?? "";
      final match = _distanceValue.firstMatch(name);
      return match != null ? "${match.group(1)} km" : name;
    }).toList();

    return XLEvent(
      id: first["e_id"],
      title: distances.join(" · "),
      date: DateTime.fromMillisecondsSinceEpoch(first["e_date"] * 1000),
      time: first["e_time"],
      imageUrl: _thumbnailUrl,
      location: location.isNotEmpty ? location : "XLkm Run София",
      detailsUrl: " ",
      distances: distances,
    );
  }
}
