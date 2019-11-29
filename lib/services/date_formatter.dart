class DateFormatter {

  static String getDate(DateTime dateTime) {
    return "${dateTime.day}.${dateTime.month}.${dateTime.year}";
  }

  static String getTime(DateTime dateTime) {
    return "${dateTime.hour}:${dateTime.minute}";
  }

}