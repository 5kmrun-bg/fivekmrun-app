import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:fivekmrun_flutter/state/resource.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RunsResource extends Resource<List<Run>> {
  Run _bestRun;
  Run _lastRun;

  Run get bestRun {
    if (_bestRun == null) {
      _bestRun =
          value?.reduce((a, b) => a.timeInSeconds < b.timeInSeconds ? a : b);
    }
    return _bestRun;
  }

  Run get lastRun {
    if (_lastRun == null) {
      _lastRun = value?.first;
    }
    return _lastRun;
  }

  @override
  void reset() {
    super.reset();
    _bestRun = null;
    _lastRun = null;
  }

  @override
  Future<http.Response> fetch(int id) {
    return http.get("${constants.runsUrl}$id");
  }

  @override
  List<Run> parse(Document doc) {
    List<Run> runs = List<Run>();
    final rows = doc.querySelectorAll("table tbody tr");

    rows.forEach((elem) {
      final cols = elem.querySelectorAll("td");
      if (cols.length == 9) {
        runs.add(extractRun(cols));
      }
    });

    // runs.sort((a, b) => a.date.compareTo(b.date));

    return runs;
  }

  Run extractRun(List<Element> cells) {
    return Run(
      location: cells[0].text,
      date: extractDate(cells[1]),
      position: extractPosition(cells[2]),
      time: cells[3].text,
      timeInSeconds: extractTimeInSeconds(cells[3]),
      differenceFromPrevious: cells[4].text,
      differenceFromBest: cells[5].text,
      speed: extractSpeed(cells[6]),
      pace: cells[7].text,
      notes: cells[8].text,
    );
  }

  DateTime extractDate(Element cell) {
    DateFormat inputFormat = DateFormat(Constants.DATE_FORMAT);
    DateTime date = inputFormat.parse(cell.text);
    return date;
  }

  int extractPosition(Element cell) {
    return int.tryParse(cell.text);
  }

  String extractSpeed(Element cell) {
    final untrimmedSpeed = cell.text;
    return untrimmedSpeed.substring(0, untrimmedSpeed.length - 5);
  }

  int extractTimeInSeconds(Element cell) {
    List<String> parts = cell.text.split(':');
    return int.tryParse(parts[0]) * 60 + int.tryParse(parts[1]);
  }
}
