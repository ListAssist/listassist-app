class Bill {
  final String url;

  Bill({this.url});

  factory Bill.fromURL(String url) {
    if(url == null || url.length < 1)
      return null;
    return Bill(
        url: url
    );
  }
}