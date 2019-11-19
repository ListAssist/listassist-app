import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:listassist/widgets/camera-scanner/camera-scanner.dart';

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
                    title: new Text("${inputs[index].name}", style: inputs[index].checked ? TextStyle(decoration: TextDecoration.lineThrough, decorationThickness: 3) : null),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (bool val) { itemChange(val, index); }
                  )
                );
              }
            )
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        closeManually: false,
        curve: Curves.easeIn,
        overlayOpacity: 0.35,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: Icon(Icons.check),
              backgroundColor: Colors.green,
              label: "Complete",
              labelStyle: TextStyle(fontSize: 18.0, color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white),
              onTap: _showDialog
          ),
          SpeedDialChild(
            child: Icon(Icons.delete),
            backgroundColor: Colors.red,
            label: "Delete",
            labelStyle: TextStyle(fontSize: 18.0, color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white),
            onTap: null,
          ),
          SpeedDialChild(
            child: Icon(Icons.camera),
            backgroundColor: Colors.blue,
            label: "Image Check",
            labelStyle: TextStyle(fontSize: 18.0, color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PictureShow())),
          ),
        ],
      ),
    );
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
}