import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:provider/provider.dart';

class AddShoppinglist extends StatefulWidget {
  @override
  _AddShoppinglist createState() => _AddShoppinglist();
}

class _AddShoppinglist extends State<AddShoppinglist> {

  User user;

  final _productTextController = TextEditingController();
  final _nameTextController = TextEditingController();

  Algolia algolia = Application.algolia;

  bool _nameIsValid = false;
  bool _productsIsNotEmpty = true;
  bool _productIsValid = true;
  bool _listIsValid = false;

  List<Item> _products = [
  ];

  void itemChange(bool val, int index){
    setState(() {
      _products[index].bought = val;
    });
  }

  _addProduct(product) {
    _productsIsNotEmpty = true;
    _productIsValid = true;
    for(var i = 0; i < _products.length; i++){
      if(_products[i].name == product){
        _productIsValid = false;
        return;
      }
    }
    if(_nameIsValid){
      _listIsValid = true;
    }

    setState(() {
      _productTextController.clear();
      _products.add(new Item(name: product, bought: false));
    });
  }

  _createShoppingList() {
      if(!_listIsValid) {
        return;
      }

      databaseService.createList(user.uid, ShoppingList(
        id: "",
        created: Timestamp.now(),
        name: _nameTextController.text,
        type: "pending",
        items: _products,
      ));

      Navigator.pop(context);
  }

  _searchProducts(String search) async{
    AlgoliaQuery query = algolia.instance.index('products').search(search);

    AlgoliaQuerySnapshot snap = await query.getObjects();

    print("keko");
    print(snap.hits[0].data);

    List<dynamic> hits = List<dynamic>();
    snap.hits.forEach((h) => {
      hits.add(h.data)
    });
    return hits;
  }


  FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _nameTextController.dispose();
    _productTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    user = Provider.of<User>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primary,
        title: Text("Neue Einkaufsliste erstellen"),
      ),
      body: Container(
          child: ListView(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    controller: _nameTextController,
                    autofocus: true,
                    onChanged: (text){
                      setState(() {
                        if(text.length > 1){
                          _nameIsValid = true;
                          if(_productsIsNotEmpty) {
                            _listIsValid = true;
                          }
                        } else {
                          _nameIsValid = false;
                          _listIsValid = false;
                        }
                        text.length > 1 ? _nameIsValid = true : _nameIsValid = false;
                      });
                    },
                    onSubmitted: (term) => {
                      FocusScope.of(context).requestFocus(myFocusNode),
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(14),
                      labelText: 'Name',
                      errorText: _nameIsValid ? null : 'Bitte einen gültigen Namen eingeben',
                    ),
                  )
              ),
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[


                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TypeAheadField(

                              suggestionsCallback: (pattern) async{
                                if(pattern.isNotEmpty) {
                                  return await _searchProducts(pattern);
                                }
                                return null;
                              },
                              itemBuilder:  (context, suggestion) {
                                print(suggestion);
                                return ListTile(
                                  leading: suggestion['category'] == "Allgemein" ? Icon(Icons.store) : Icon(Icons.directions_run),
                                  title: Text(suggestion['name']),
                                  subtitle: Text(suggestion['category']),
                                );
                              },
                              onSuggestionSelected:  (suggestion) {
                                _addProduct(suggestion['name']);
                                _productTextController.clear();
                              },

                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _productTextController,
                                focusNode: myFocusNode,
                                onSubmitted: (term) => {
                                  if(_productTextController.text.length > 1){
                                    _addProduct(_productTextController.text)
                                  },
                                  FocusScope.of(context).requestFocus(myFocusNode),
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(14),
                                  labelText: 'Produkt eingeben',
                                  errorText: _productsIsNotEmpty ? _productIsValid ? null : 'Dieses Produkt ist bereits in der Einkaufsliste' : 'Die Einkaufsliste benötigt Produkte',
                                ),
                              ),


                              errorBuilder: (BuildContext context, Object error) =>
                                  Text(
                                      '$error' + "HEEE MAN KANN DIE ERRORS AUSBLENDEN",
                                      style: TextStyle(
                                          color: Theme.of(context).errorColor
                                      )
                                  ),

                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () =>
                            {
                              if(_productTextController.text.length > 1){
                                _addProduct(_productTextController.text)
                              },
                            }
                          ),


                          PopupMenuButton<int>(
                            itemBuilder: (context) => [



                              PopupMenuItem(
                                  value: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Icon(Icons.search),
                                      Text("Suchen")
                                    ],
                                  )
                              ),

                              PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Icon(Icons.mic),
                                      Text("Spracheingabe")
                                    ],
                                  )
                              ),

                              PopupMenuItem(
                                value: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Icon(Icons.category),
                                    Text("Kategorien")
                                  ],
                                )
                              ),

                            ]
                          ),
                        ],
                      ),

                      Container(
                        child: Text("Produkte:"),
                        margin: EdgeInsets.only(top: 25.0),
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 15.0),
                        constraints: BoxConstraints(
                          maxHeight: 530,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Color(0xffeeeeee),
                        ),
                        child: ListView.builder(
                            itemCount: _products.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            reverse: true,
                            itemBuilder: (BuildContext context, int index){
                              return Dismissible(
                                key: Key(_products[index].name),
                                direction: DismissDirection.startToEnd,
                                background: Container(
                                  child: Icon(Icons.delete, color: Colors.white,),
                                  alignment: AlignmentDirectional.centerStart,
                                  padding: EdgeInsets.only(left: 15),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      stops: [0, 0.3],
                                      colors: [Colors.red, Color(0xffeeeeee)],
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                ),
                                onDismissed: (direction){
                                  setState(() {
                                    _products.removeAt(index);
                                    if(_products.length > 0){
                                      _productsIsNotEmpty = true;
                                      if(_nameIsValid){
                                        _listIsValid = true;
                                      }
                                    } else {
                                      _productsIsNotEmpty = false;
                                      _listIsValid = false;
                                    }
                                  });
                                },
                                child: Container(
                                    child: CheckboxListTile(
                                        value: _products[index].bought,
                                        title: new Text("${_products[index].name}"),
                                        controlAffinity: ListTileControlAffinity.leading,
                                        onChanged: (bool val) { itemChange(val, index); },
                                        secondary: IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red,),
                                            onPressed: ()=>(){},
                                        ),
                                    )
                                ),
                              );
                            }
                        ),
                      ),
                    ],
                  )
              ),
            ],
          )
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          backgroundColor: _listIsValid ? Colors.green : Colors.grey,
          onPressed: () => _listIsValid ? _createShoppingList() : null,
      ),
    );
  }

}

class Application {
  static final Algolia algolia = Algolia.init(
    applicationId: 'K2QDRTR8CM',
    apiKey: 'd09e06f1376cf1137d8e72c9bd41bece',
  );
}