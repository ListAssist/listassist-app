import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/widgets/camera-scanner/picture-show.dart';
import 'package:provider/provider.dart';


class ShoppingListDetail extends StatefulWidget {
  final int index;
  ShoppingListDetail({this.index});

  @override
  _ShoppingListDetail createState() => _ShoppingListDetail();
}

class _ShoppingListDetail extends State<ShoppingListDetail> {

  String name = "";

  @override
  Widget build(BuildContext context) {
    ShoppingList list = Provider.of<List<ShoppingList>>(context)[widget.index];

    void itemChange(bool val, int index){
      setState(() {
        list.items[index].bought = val;
      });
    }

    name = list.name;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(list.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: Text("${list.items.map((e) => e.bought ? 1 : 0).reduce((a, b) => a + b)} von ${list.items.length} Sachen gekauft", style: Theme.of(context).textTheme.headline)
          ),
          Expanded(
            child: ListView.builder(
              itemCount: list.items.length,
              itemBuilder: (BuildContext context, int index){
                return Container(
                  child: CheckboxListTile(
                    value: list.items[index].bought,
                    title: new Text("${list.items[index].name}", style: list.items[index].bought ? TextStyle(decoration: TextDecoration.lineThrough, decorationThickness: 3) : null),
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
        overlayColor: Colors.black,
        overlayOpacity: 0.35,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: Icon(Icons.check),
              backgroundColor: Colors.green,
              label: "Complete",
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: _showDialog
          ),
          SpeedDialChild(
            child: Icon(Icons.delete),
            backgroundColor: Colors.red,
            label: "Delete",
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: null,
          ),
          SpeedDialChild(
            child: Icon(Icons.camera),
            backgroundColor: Colors.blue,
            label: "Image Check",
            labelStyle: TextStyle(fontSize: 18.0),
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
                      TextSpan(text: "$name", style: TextStyle(fontWeight: FontWeight.bold)),
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