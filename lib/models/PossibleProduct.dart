class PossibleProduct {
  List<String> name;
  double price;

  PossibleProduct({this.name, this.price});

  @override
  String toString() {
    return "Product Name: $name \n Price of the product: ${price != null ? price : "N/A"} \n";
  }

}