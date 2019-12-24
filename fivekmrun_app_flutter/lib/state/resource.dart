import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParse;
import 'package:html/dom.dart';

abstract class Resource<T> extends ChangeNotifier {
  bool _loading = false;
  int currentlyLoadingId;
  T _value;

  bool get loading => _loading;
  set loading(bool value) {
    if (_loading != value) {
      _loading = value;
      notifyListeners();
    }
  }

  T get value => _value;
  set value(T v) {
    if (_value != v) {
      _value = v;
      notifyListeners();
      valueUpdated(v);
    }
  }

  void load(int id) async {
    if (id == currentlyLoadingId) {
      return;
    }

    this.loading = true;
    this.value = null;
    currentlyLoadingId = id;
    var response = await fetch(id);
    // await Future.delayed(Duration(seconds: 2),() {});

    if (response.statusCode != 200) {
      this.loading = false;
      //TODO: error handling
      return;
    }

    if (currentlyLoadingId == id) {
      String body = utf8.decode(response.bodyBytes);
      Document doc = htmlParse.parse(body, encoding: "utf8");

      T parsedObj = parse(doc);

      this.value = parsedObj;
      this.loading = false;
    }
  }

  void reset() {
    loading = false;
    currentlyLoadingId = null;
    value = null;
  }

  void valueUpdated(T val) {}
  Future<http.Response> fetch(int id);
  T parse(Document doc);
}
