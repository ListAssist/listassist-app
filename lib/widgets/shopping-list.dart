import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:listassist/widgets/shoppinglist-detail.dart';


class ShoppingList extends StatelessWidget {
  final String title;
  final int total;
  final int bought;
  ShoppingList({this.title = 'Einkaufsliste', this.total = 10, this.bought = 7});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ShoppingListDetail(title: title)),
        ),
        child: Card(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.title),
                  Text("$bought/$total eingekauft")
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}