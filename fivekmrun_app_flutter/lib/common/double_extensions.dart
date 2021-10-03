extension DoubleExtension on int {
  String metersToKm() {
    return (this / 1000).toStringAsFixed(2);
  }
}
