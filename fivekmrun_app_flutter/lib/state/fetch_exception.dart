import 'package:http/http.dart' as http;

/// Thrown when an endpoint answers with something we can't parse as run/event
/// data — a non-200 status, or a body that isn't JSON.
///
/// This exists so callers can tell "the fetch failed" apart from "the fetch
/// succeeded and there is nothing to show". Returning an empty list for both
/// meant a transient server error silently wiped the user's history.
class FetchException implements Exception {
  /// What we were trying to load, e.g. "5km runs". Used in the message only.
  final String resource;
  final int statusCode;
  final String? contentType;

  const FetchException(this.resource, this.statusCode, this.contentType);

  @override
  String toString() => "FetchException: could not load $resource "
      "(status $statusCode, content-type ${contentType ?? "none"})";
}

/// Whether a response carries JSON we can parse.
///
/// The content-type is matched on its prefix: the API returns
/// `application/json;charset=utf-8;` today, but an exact-match check turns any
/// change in casing, spacing or the trailing semicolon into a silent
/// "no results" for every user.
bool isJsonResponse(int statusCode, String? contentType) {
  if (statusCode != 200 || contentType == null) {
    return false;
  }

  return contentType.trimLeft().toLowerCase().startsWith("application/json");
}

/// Throws a [FetchException] unless [response] is a 200 carrying JSON.
void ensureJsonResponse(http.Response response, String resource) {
  final contentType = response.headers["content-type"];

  if (!isJsonResponse(response.statusCode, contentType)) {
    throw FetchException(resource, response.statusCode, contentType);
  }
}
