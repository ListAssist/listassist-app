class Product {
  final String name;
  bool category;

  Item({this.name, this.category});

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'category': category,
      };

  factory Item.fromMap(Map data) {
    data = data ?? { };

    return Item(
        name: data["name"],
        category: data["category"]
    );
  }
}