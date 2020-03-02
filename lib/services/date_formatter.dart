class DateFormatter {

  static String getDate(DateTime dateTime) {
    String day = dateTime.day.toString().padLeft(2, "0");
    String month = dateTime.month.toString().padLeft(2, "0");
    return "$day.$month.${dateTime.year}";
  }

  static String getTime(DateTime dateTime) {
    return "${dateTime.hour}:${dateTime.minute}";
  }

  static String getDateAndTime(DateTime dateTime) {
    return "${getDate(dateTime)} ${getTime(dateTime)}";
  }

}