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
  //List<String> _products = ["Milch", "Reis", "Bier"];

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
    setState(() {
      _productTextController.clear();
      _products.add(new Item(product, false));
    });
  }

  _createGroup() {
    print(_products);
    print(_nameTextController.text);
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
        title: Text("Neue Einkaufslistes erstellen"),
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
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () =>
                            {
                              if(_productTextController.text.length > 1){
                                _addProduct(_productTextController.text)
                              },                            }
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20.0),
                        height: 500,
                        child: ListView.builder(
                            itemCount: _products.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            reverse: true,
                            itemBuilder: (BuildContext context, int index){
                              return Container(
                                  child: CheckboxListTile(
                                      value: _products[index].checked,
                                      title: new Text("${_products[index].name}"),
                                      controlAffinity: ListTileControlAffinity.trailing,
                                      onChanged: (bool val) { itemChange(val, index); }
                                  )
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
          onPressed: () => _createGroup()
      ),
    );
  }

}