extension DateTimeExtensions on DateTime {
  DateTime lastSaturday() {
    DateTime date = this;
    while (date.weekday != 6) {
      date = date.subtract(Duration(days: 1));
    }

    return this;
  }
}
