extension DoubleExtension on double {
  String parseMetersToKilometers() {
    return (this / 1000).toStringAsFixed(2) + " км";
  }
}