import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listassist/widgets/shoppinglist/search_items_view.dart';

class CreateShoppingListView extends StatefulWidget {
  @override
  _CreateShoppingListView createState() => _CreateShoppingListView();
}

class _CreateShoppingListView extends State<CreateShoppingListView> {

  Color _backgroundColor = Colors.blueAccent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          backgroundColor: Colors.green,
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SearchItemsView()));
          },
        ),
        appBar: AppBar(
          backgroundColor: _backgroundColor,
          leading: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                Navigator.pop(context);
              },
          ),
          elevation: 0,
        ),
        body: Column(children: <Widget>[
          Container(
            height: 120.0,
            child: Stack(
              children: <Widget>[
                Container(
                  color: _backgroundColor,
                  width: MediaQuery.of(context).size.width,
                  height: 120.0,
                ),
                Positioned(
                  top: 50.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.0),
                          color: Colors.white
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              //controller: _searchController,
                              style: TextStyle(fontSize: 20),
                              onChanged: (text) async {
                                //_products = await _searchProducts(text);
                                //setState(() {});
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Neue Einkaufsliste",
                                  contentPadding: EdgeInsets.all(17)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: _backgroundColor,
            ),
          )
        ])
    );
  }
}
