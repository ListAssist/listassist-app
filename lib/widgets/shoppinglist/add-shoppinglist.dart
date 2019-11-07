import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_math/extended_math.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  bool _nameIsValid = false;
  bool _productsIsNotEmpty = true;
  bool _productIsValid = true;
  bool _listIsValid = false;

  var rng = new Random();

  var _products = [
    new Item(name: "Apfel", bought: false),
    new Item(name: "Kekse", bought: false),
    new Item(name: "Seife", bought: false),
    new Item(name: "Öl", bought: false)
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
                      border: UnderlineInputBorder(),
                      contentPadding: EdgeInsets.all(3),
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
                      Text("Produkte:"),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _productTextController,
                              focusNode: myFocusNode,
                              onSubmitted: (term) => {
                                if(_productTextController.text.length > 1){
                                  _addProduct(_productTextController.text)
                                },
                                FocusScope.of(context).requestFocus(myFocusNode),
                              },
                              //keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                contentPadding: EdgeInsets.all(3),
                                labelText: 'Produkt eingeben',
                                errorText: _productsIsNotEmpty ? _productIsValid ? null : 'Dieses Produkt ist bereits in der Einkaufsliste' : 'Die Einkaufsliste benötigt Produkte',
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
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 25.0),
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
                                        controlAffinity: ListTileControlAffinity.trailing,
                                        onChanged: (bool val) { itemChange(val, index); }
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