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

  factory Event.fromKidsJson(dynamic d) => KidsEvent(
        id: d["e_id"],
        title: d["e_title"],
        date: DateTime.fromMillisecondsSinceEpoch(d["e_date"] * 1000),
        time: d["e_time"],
        imageUrl:
            "https://firebasestorage.googleapis.com/v0/b/kmrunbg.appspot.com/o/kids-run-bw.png?alt=media&token=a782fe29-6422-4b61-95b1-c4e7f81ddd5c",
        location: d["n_name"],
        detailsUrl: " ",
      );


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
  final List<XLRegistrationLink> registrationLinks;

  XLEvent({
    required super.id,
    required super.title,
    required super.date,
    required super.time,
    required super.imageUrl,
    required super.location,
    required super.detailsUrl,
    required this.distances,
    required this.registrationLinks,
  });

  static const String _thumbnailUrl =
      "https://firebasestorage.googleapis.com/v0/b/kmrunbg.appspot.com/o/xl-run-thumbnail-bw.png?alt=media&token=bdccfa3c-9a5a-4792-bb04-bafaaad6442a";

  // n_name is usually "<place name> <distance> км", e.g. "с. Кътина 4.8 км",
  // but some events instead suffix a tier word ("Къса"/"Средна"/"XL") with no
  // number at all, and single-distance/relay events carry no suffix. So
  // rather than assume a numeric suffix, the location is derived as the
  // longest common prefix shared by every row in the group.
  static final RegExp _distanceSuffix =
      RegExp(r'\s+[\d.,]+\s*км\.?\s*$', caseSensitive: false);
  static final RegExp _distanceValue =
      RegExp(r'([\d.,]+)\s*км', caseSensitive: false);

  static const String _registerUrlPrefix = "https://5kmrun.bg/xlrun/event/";

  factory XLEvent.fromRows(List<dynamic> rows) {
    final first = rows.first;
    final List<String> rawNames =
        rows.map<String>((row) => (row["n_name"] ?? "") as String).toList();

    final String location = _locationFrom(rawNames);

    // Per-row distance label, kept empty when a row has no distance suffix
    // to parse (relay/single-tier events) — unlike `distances` below, this
    // stays index-aligned with `rows` so it can be paired with each row's
    // own e_id for the per-distance registration link.
    final List<String> labels = rawNames.map((name) {
      final String remainder = _stripPrefix(name, location).trim();
      if (remainder.isEmpty) return "";
      final match = _distanceValue.firstMatch(remainder);
      return match != null ? "${match.group(1)} km" : remainder;
    }).toList();

    final List<String> distances = labels.where((d) => d.isNotEmpty).toList();

    // The registration URL is per distance tier, since each row is its own
    // event id on the website — not the group as a whole.
    final List<XLRegistrationLink> registrationLinks = [];
    for (var i = 0; i < rows.length; i++) {
      final eventId = rows[i]["e_id"];
      if (eventId == null) continue;
      registrationLinks.add(XLRegistrationLink(
        label: labels[i],
        url: "$_registerUrlPrefix$eventId",
      ));
    }

    return XLEvent(
      id: first["e_id"],
      title: distances.join(" · "),
      date: DateTime.fromMillisecondsSinceEpoch(first["e_date"] * 1000),
      time: first["e_time"],
      imageUrl: _thumbnailUrl,
      location: location.isNotEmpty ? location : "XLkm Run София",
      detailsUrl:
          registrationLinks.isNotEmpty ? registrationLinks.first.url : "",
      distances: distances,
      registrationLinks: registrationLinks,
    );
  }

  static String _locationFrom(List<String> names) {
    if (names.isEmpty) return "";
    if (names.length == 1) {
      final stripped = names.first.replaceAll(_distanceSuffix, "").trim();
      return stripped.isNotEmpty ? stripped : names.first.trim();
    }

    String prefix = names.first;
    for (final name in names.skip(1)) {
      prefix = _commonPrefix(prefix, name);
    }
    prefix = prefix.trim();

    // A too-short common prefix means these rows likely don't actually
    // share a location name; fall back to stripping a numeric suffix off
    // the first row instead of grouping on a near-empty string.
    if (prefix.length < 3) {
      return names.first.replaceAll(_distanceSuffix, "").trim();
    }
    return prefix;
  }

  static String _commonPrefix(String a, String b) {
    final int len = a.length < b.length ? a.length : b.length;
    int i = 0;
    while (i < len && a[i] == b[i]) {
      i++;
    }
    return a.substring(0, i);
  }

  static String _stripPrefix(String name, String prefix) {
    if (prefix.isNotEmpty && name.startsWith(prefix)) {
      return name.substring(prefix.length);
    }
    return name;
  }
}

/// A KidsRun event — single-distance, unlike [XLEvent]. Exists as its own
/// type purely so the future-events list can tell it apart from a regular
/// or XL event and show a distinct "Kids" badge.
class KidsEvent extends Event {
  KidsEvent({
    required super.id,
    required super.title,
    required super.date,
    required super.time,
    required super.imageUrl,
    required super.location,
    required super.detailsUrl,
  });
}

/// One distance tier's registration link on a grouped [XLEvent] card. Each
/// tier is its own event id on the website, so the registration URL varies
/// per distance rather than per day/location.
class XLRegistrationLink {
  final String label;
  final String url;

  const XLRegistrationLink({required this.label, required this.url});
}
