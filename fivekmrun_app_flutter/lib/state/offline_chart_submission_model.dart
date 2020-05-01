class OfflineChartSubmissionModel {
  final String userId;
  final int elapsedTime;
  final double distance;
  final DateTime startDate;
  final String mapPath;
  final List<double> startLocation;

  OfflineChartSubmissionModel({
    this.userId,
    this.elapsedTime,
    this.distance,
    this.startDate,
    this.mapPath,
    this.startLocation
  });
}