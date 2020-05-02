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
    this.startLocation
  });
}