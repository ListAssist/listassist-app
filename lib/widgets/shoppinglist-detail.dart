import 'package:flutter/material.dart';

class Item {
  String name;
  bool checked;

  Item(String name, bool checked) {
    this.name = name;
    this.checked = checked;
  }
}

class ShoppingListDetail extends StatefulWidget {
  final String title;
  ShoppingListDetail({this.title = "Einkaufsliste"});

  @override
  _ShoppingListDetail createState() => _ShoppingListDetail(title: title);
}

class _ShoppingListDetail extends State<ShoppingListDetail> {

  String title;
  _ShoppingListDetail({this.title: "Einkaufsliste"});

  var inputs = [
    new Item("Apfel", false),
    new Item("Kekse", false),
    new Item("Seife", true),
    new Item("Öl", true),
    new Item("Batterien", true),
    new Item("Brot", false),
    new Item("Brot", false),
    new Item("Brot", false),
    new Item("Brot", false),
    new Item("Kakao", false),
    new Item("Milch", false)];

  void itemChange(bool val, int index){
    setState(() {
      inputs[index].checked = val;
    });
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Einkaufsliste abschließen"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(text:
                  TextSpan(
                    style: new TextStyle(
                      color: Theme.of(context).textTheme.title.color,
                    ),
                    children: <TextSpan> [
                      TextSpan(text: "Sind Sie sicher, dass Sie die Einkaufsliste "),
                      TextSpan(text: "${this.title}", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: " abschließen möchten?")
                    ]
                  )
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.red,
              child: Text("Abbrechen"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Abschließen"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(this.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: Text("${inputs.map((e) => e.checked ? 1 : 0).reduce((a, b) => a + b)} von ${inputs.length} Sachen gekauft", style: Theme.of(context).textTheme.headline)
          ),
          Expanded(
            child: ListView.builder(
              itemCount: inputs.length,
              itemBuilder: (BuildContext context, int index){
                return Container(
                  child: CheckboxListTile(
                    value: inputs[index].checked,
                    title: new Text("${inputs[index].name}"),
                    controlAffinity: ListTileControlAffinity.trailing,
                    onChanged: (bool val) { itemChange(val, index); }
                  )
                );
              }
            )
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                child: Icon(Icons.check),
                onPressed: () { _showDialog(); }
              ),
            )
          )
        ],
      )
    );
  }
}