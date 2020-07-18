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

  OfflineChartSubmissionModel({
    this.userId,
    this.elapsedTime,
    this.distance,
    this.startDate,
    this.mapPath,
    this.startGeoLocation,
    this.elevationLow,
    this.elevationHigh,
    this.elevationGainedTotal,
    this.startLocation,
    this.totalDistance,
    this.totalElapsedTime
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': this.userId,
      'elapsedTime': this.elapsedTime,
      'distance': this.distance,
      'startDate': this.startDate.toString(),
      'mapPath': this.mapPath,
      'startGeoLocation': this.startGeoLocation,
      'elevationLow': this.elevationLow,
      'elevationHigh': this.elevationHigh,
      'elevationGainedTotal': this.elevationGainedTotal,
      'startLocation': this.startLocation
    };
  }
}