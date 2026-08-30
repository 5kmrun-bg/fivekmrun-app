class OfflineChartSubmissionModel {
  final String userId;
  final int elapsedTime;
  final double distance;
  final DateTime startDate;
  final String mapPath;
  final List<double> startGeoLocation;
  final double elevationLow;
  final double elevationHigh;
  final double elevationGainedTotal;
  final String startLocation;
  final double totalDistance;
  final int totalElapsedTime;
  final String stravaLink;
  final List<int?>? segments;

  OfflineChartSubmissionModel(
      {required this.userId,
      required this.elapsedTime,
      required this.distance,
      required this.startDate,
      required this.mapPath,
      required this.startGeoLocation,
      required this.elevationLow,
      required this.elevationHigh,
      required this.elevationGainedTotal,
      required this.startLocation,
      required this.totalDistance,
      required this.totalElapsedTime,
      required this.stravaLink,
      required this.segments});

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'elapsedTime': elapsedTime,
      'distance': distance,
      'startDate': startDate.toString(),
      'mapPath': mapPath,
      'startGeoLocation': startGeoLocation,
      'elevationLow': elevationLow,
      'elevationHigh': elevationHigh,
      'elevationGainedTotal': elevationGainedTotal,
      'startLocation': startLocation,
      'stravaLink': stravaLink,
      'segments': segments.toString()
    };
  }
}
