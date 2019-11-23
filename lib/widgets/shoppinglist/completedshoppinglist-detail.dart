import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:listassist/models/CompletedShoppingList.dart';

class CompletedShoppingListDetail extends StatelessWidget {
  final int index;
  CompletedShoppingListDetail({this.index});


  @override
  Widget build(BuildContext context) {
    CompletedShoppingList list = Provider.of<List<CompletedShoppingList>>(context)[this.index];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(list.name),
      ),
      body: Text("kek"),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
      )
    );
  }

}