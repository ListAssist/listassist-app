import 'package:extended_math/extended_math.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Item {
  String name;
  bool checked;

  Item(String name, bool checked) {
    this.name = name;
    this.checked = checked;
  }
}

class AddShoppinglist extends StatefulWidget {
  @override
  _AddShoppinglist createState() => _AddShoppinglist();
}

class _AddShoppinglist extends State<AddShoppinglist> {

  final _productTextController = TextEditingController();
  final _nameTextController = TextEditingController();

  bool _nameIsValid = true;
  bool _productsIsValid = true;

  var rng = new Random();

  var _products = [
  new Item("Apfel", false),
  new Item("Kekse", false),
  new Item("Seife", false),
  new Item("Öl", false)];

  void itemChange(bool val, int index){
    setState(() {
      _products[index].checked = val;
    });
  }

  _addProduct(product) {
    for(var i = 0; i < _products.length; i++){
      if(_products[i].name == product){
        return;
      }
    }

    setState(() {
      _productTextController.clear();
      _products.add(new Item(product, false));
    });
  }

  _createShoppingList() {
      setState(() {
        _nameTextController.text.length > 1 ? _nameIsValid = true : _nameIsValid = false;
        _products.length > 0 ? _productsIsValid = true : _productsIsValid = false;
      });

      if(!_nameIsValid) return;
      if(!_productsIsValid) return;
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
                    onSubmitted: (term) => {
                      FocusScope.of(context).requestFocus(myFocusNode),
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      contentPadding: EdgeInsets.all(3),
                      labelText: 'Name',
                      errorText: _nameIsValid ? null : 'Bitte einen Namen eingeben',
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
                                errorText: _productsIsValid ? null : 'Die Einkaufsliste benötigt Produkte',
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
                          borderRadius: BorderRadius.all(Radius.circular(10)),
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
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                onDismissed: (direction){
                                  setState(() {
                                    _products.removeAt(index);
                                  });
                                },
                                child: Container(
                                    child: CheckboxListTile(
                                        value: _products[index].checked,
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
          backgroundColor: Colors.green,
          onPressed: () => _createShoppingList()
      ),
    );
  }

}