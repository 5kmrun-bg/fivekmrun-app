import 'package:fivekmrun_flutter/state/resource.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:fivekmrun_flutter/state/user_model.dart';
import 'package:fivekmrun_flutter/constants.dart' as constants;

import 'package:http/http.dart' as http;
import 'package:html/dom.dart';

class ResultsResource extends Resource<List<Result>> {
  @override
  Future<http.Response> fetch(int id) {
    return http.get("${constants.resultsUrl}$id&type=1");
  }

  @override
  List<Result> parse(Document doc) {
    final rows = doc.querySelectorAll("div.table-responsive1 table tbody tr");

    var results = rows.map((row) {
      return Result(
        position: int.tryParse(row.children[0].text),
        name: row.children[2].text,
        time: row.children[3].text,
        totalRuns: row.children[11].text,
        sex: row.children[5].text,
      );
    }).toList(growable: false);

    return results;
  }
}
