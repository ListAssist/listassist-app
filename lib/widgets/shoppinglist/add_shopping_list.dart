import 'dart:async';

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
  Timer _debounce;

  bool _nameIsValid = false;
  bool _productsIsNotEmpty = true;
  bool _productIsValid = true;
  bool _listIsValid = false;

  List<Item> _products = [
  ];

  List<Item> _productsTicked = [

  ];

  _tickItem(int index){
    setState(() {
      _products[index].bought = true;
      _productsTicked.add(_products[index]);
      _products.removeAt(index);
    });
  }

  _untickItem(int index){
    setState(() {
      _productsTicked[index].bought = false;
      _products.add(_productsTicked[index]);
      _productsTicked.removeAt(index);
    });
  }

  bool _productsIsEmpty(){
    return _products.isEmpty && _productsTicked.isEmpty;
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
    for(var i = 0; i < _productsTicked.length; i++){
      if(_productsTicked[i].name == product){
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
                        text.length > 1 ? _nameIsValid = true : _nameIsValid = false;
                        _listIsValid = !_productsIsEmpty() && _nameIsValid;
                      });
                    },
                    onSubmitted: (term) => {
                      FocusScope.of(context).requestFocus(myFocusNode),
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(14),
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.list),
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
                                print("Suggestion: $suggestion");
                                return ListTile(
                                  leading: suggestion['category'] == "Allgemein" ? Icon(Icons.local_dining) : Icon(Icons.directions_run),
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
                                  prefixIcon: Icon(Icons.add_circle_outline),
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
                        child: Text(_products.isNotEmpty || _productsTicked.isNotEmpty ? "Produkte:" : ""),
                        margin: EdgeInsets.only(top: 25.0, bottom: 15.0),
                      ),

                      _products.isNotEmpty ? Container(
                        margin: EdgeInsets.only(bottom: 15.0),
                        child: _showProductList(false),
                      ) : Container(height: 0, width: 0,),

                      Container(
                        //margin: EdgeInsets.only(top: 15.0),
                        child: _productsTicked.isNotEmpty ?
                          ExpansionTile(
                            title: Text("Abgehakt"),
                            leading: Icon(Icons.beenhere),
                            trailing: Icon(Icons.keyboard_arrow_down),
                            children: <Widget>[
                              _showProductList(true)
                            ],
                          ) : Container(height: 0, width: 0,),
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



  _showProductList (bool ticked){
    return Container(
      constraints: BoxConstraints(
        maxHeight: 530,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: Color(0xffeeeeee),
      ),
      child: ListView.builder(
          itemCount: ticked ? _productsTicked.length : _products.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          reverse: true,
          itemBuilder: (BuildContext context, int index){
            return Dismissible(
              key: Key(ticked ? _productsTicked[index].name : _products[index].name),
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
                  ticked ? _productsTicked.removeAt(index) : _products.removeAt(index);
                  _listIsValid = !_productsIsEmpty() && _nameIsValid;
                });
              },

              child: Container(
                  child: CheckboxListTile(
                    value: ticked ? _productsTicked[index].bought : _products[index].bought,
                    title: ticked ?
                      Text("${_productsTicked[index].name}",  style: TextStyle(decoration: TextDecoration.lineThrough))
                        :
                      Text( "${_products[index].name}"),

                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (bool val) { ticked ? _untickItem(index) : _tickItem(index); },
                    secondary: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red,),
                      onPressed: (){
                        setState(() {
                          ticked ? _productsTicked.removeAt(index) : _products.removeAt(index);
                          _listIsValid = !_productsIsEmpty() && _nameIsValid;
                        });
                      },
                    ),
                  )
              ),
            );
          }
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