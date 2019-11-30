import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:provider/provider.dart';

class EditShoppingList extends StatefulWidget {
  final int index;
  EditShoppingList({this.index});

  @override
  _EditShoppingListState createState() => _EditShoppingListState();
}

class _EditShoppingListState extends State<EditShoppingList> {

  TextEditingController _nameTextController;

  bool firstLoad = true;
  List<Item> copyItems;

  @override
  Widget build(BuildContext context) {
    ShoppingList list = Provider.of<List<ShoppingList>>(context)[widget.index];
    if(firstLoad) {
      copyItems = List.from(list.items);
      firstLoad = false;
    }

    _nameTextController = TextEditingController(text: list.name);
    return Scaffold(
      appBar: AppBar(
        title: Text("Einkaufsliste bearbeiten"),
      ),
      body: Container(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20),
                child: TextField(
                  controller: _nameTextController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.all(3),
                    labelText: 'Name der Einkaufsliste',
                  ),
                )
              ),
              Padding(
                padding: EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: copyItems.map<Widget>((i) {
                    return Container(
                      child: ListTile(
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              copyItems.remove(i);
                              print(copyItems);
                            });
                          }),
                        title: new Text("${i.name}", style: i.bought ? TextStyle(decoration: TextDecoration.lineThrough, decorationThickness: 3) : null),
                      )
                    );
                  }).toList(),
                ),
              )
            ],
          )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          //TODO: Save changes
          String newName = _nameTextController.text;
        },
      ),
    );
  }
}
