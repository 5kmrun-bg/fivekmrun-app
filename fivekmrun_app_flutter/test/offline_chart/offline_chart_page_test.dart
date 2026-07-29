import 'dart:convert';

import 'package:fivekmrun_flutter/offline_chart/offline_chart_page.dart';
import 'package:fivekmrun_flutter/state/offline_results_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../localized_app.dart';

const _jsonHeaders = {"content-type": "application/json; charset=utf-8"};

void main() {
  testWidgets(
      'wires a RefreshIndicator so pull-to-refresh reloads the current week',
      (tester) async {
    final client = MockClient((_) async =>
        http.Response(jsonEncode({"runners": []}), 200, headers: _jsonHeaders));

    await tester.pumpWidget(localizedApp(OfflineChartPage(
      thisWeekResource: OfflineResultsResource(client: client),
      lastWeekResource: OfflineResultsResource(client: client),
    )));
    await tester.pumpAndSettle();

    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('reloads results when the RefreshIndicator is triggered',
      (tester) async {
    var requestCount = 0;
    final client = MockClient((_) async {
      requestCount++;
      return http.Response(jsonEncode({"runners": []}), 200,
          headers: _jsonHeaders);
    });

    await tester.pumpWidget(localizedApp(OfflineChartPage(
      thisWeekResource: OfflineResultsResource(client: client),
      lastWeekResource: OfflineResultsResource(client: client),
    )));
    await tester.pumpAndSettle();

    final requestsBeforeRefresh = requestCount;

    await tester.fling(
        find.byType(RefreshIndicator), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(requestCount, greaterThan(requestsBeforeRefresh));
  });
}
