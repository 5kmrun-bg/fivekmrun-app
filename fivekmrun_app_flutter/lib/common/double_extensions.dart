extension DoubleExtension on double {
  String metersToKm() {
    return (this / 1000).toStringAsFixed(2);
  }
}