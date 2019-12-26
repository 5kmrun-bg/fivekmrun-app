class Run {
  final int id;
  final DateTime date;
  final int timeInSeconds;
  final String time;
  final String location;
  final String differenceFromPrevious;
  final String differenceFromBest;
  final int position;
  final String speed;
  final String notes;
  final String pace;

  Run(
      {this.date,
      this.time,
      this.timeInSeconds,
      this.location,
      this.differenceFromPrevious,
      this.differenceFromBest,
      this.position,
      this.speed,
      this.notes,
      this.pace})
      : id = ("$date#$time#$location").hashCode;
}
