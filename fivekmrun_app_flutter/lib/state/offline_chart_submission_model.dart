class OfflineChartSubmissionModel {
  final String userId;
  final int elapsedTime;
  final int distance;
  final DateTime startDate;
  final String mapPath;
  final String startLocation;
  
  OfflineChartSubmissionModel({
    this.userId,
    this.elapsedTime,
    this.distance,
    this.startDate,
    this.mapPath,
    this.startLocation
  });
}