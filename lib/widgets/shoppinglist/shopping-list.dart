import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:listassist/widgets/shoppinglist/shoppinglist-detail.dart';
import 'package:listassist/models/ShoppingList.dart' as model;
import 'package:provider/provider.dart';


class ShoppingList extends StatelessWidget {
  final int index;
  ShoppingList({this.index});

  @override
  Widget build(BuildContext context) {
    model.ShoppingList list = Provider.of<List<model.ShoppingList>>(context)[this.index];
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ShoppingListDetail(index: this.index)),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(list.name, style: Theme.of(context).textTheme.title),
              Text("${list.items.map((e) => e.bought ? 1 : 0).reduce((a, b) => a + b)}/${list.items.length} eingekauft")
            ],
          ),
        ),
      )
    );
  }
}