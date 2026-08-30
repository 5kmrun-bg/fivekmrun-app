extension DateTimeExtensions on DateTime {
  DateTime lastSaturday() {
    DateTime date = this;
    while (date.weekday != 6) {
      date = date.subtract(const Duration(days: 1));
    }

    return date;
  }

  DateTime nextSunday() {
    DateTime date = this;
    while (date.weekday != 7) {
      date = date.add(const Duration(days: 1));
    }

    return date;
  }
}
