extension IntExtensions on int {
  String parseSecondsToTimestamp() {
    int hours = this ~/ 3600;
    int minutes = (this % 3600) ~/ 60;
    int seconds = (this % 3600) % 60;

    String timestamp = minutes.toString().padLeft(2, '0') + ":" + seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      timestamp = hours.toString().padLeft(2, '0') + ":" + timestamp;
    }

    return timestamp;
  }
}