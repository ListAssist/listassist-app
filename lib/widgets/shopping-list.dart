import 'package:flutter/material.dart';


class ShoppingList extends StatelessWidget {
  final String title;
  ShoppingList({this.title = "Einkaufsliste"});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(title)
      ],
    );
  }
}