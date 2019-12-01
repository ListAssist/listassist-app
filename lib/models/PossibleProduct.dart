import 'dart:convert';

class PossibleProduct {
  List<String> name;
  double price;
  bool selected = false;

  PossibleProduct({this.name, this.price});

  static String productsToJson(List<PossibleProduct> products) {
    List<Map<String, String>> mappedProducts = [];
    products.forEach((product) {
      mappedProducts.add({
        "name": product.name.join(" "),
        "price": product.price.toString()
      });
    });
  
    return jsonEncode(mappedProducts);
  }

  @override
  String toString() {
    return "Product Name: $name \n Price of the product: ${price != null ? price : "N/A"} \n";
  }
}