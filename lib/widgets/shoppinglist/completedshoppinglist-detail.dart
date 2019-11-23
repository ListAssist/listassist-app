import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:listassist/assets/custom_icons_icons.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/services/date_formatter.dart';
import 'package:provider/provider.dart';
import 'package:listassist/models/CompletedShoppingList.dart';

class CompletedShoppingListDetail extends StatelessWidget {
  final int index;
  CompletedShoppingListDetail({this.index});


  @override
  Widget build(BuildContext context) {
    CompletedShoppingList list = Provider.of<List<CompletedShoppingList>>(context)[this.index];
    List<Item> completedItems = List<Item>();
    list.items.forEach((i) { if(i.bought) { completedItems.add(i); } });
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
              child: Text("Einkauf am ${DateFormatter.getDate(list.completed.toDate())} erledigt", style: Theme.of(context).textTheme.headline)
          ),
          Expanded(
              child: ListView.builder(
                itemCount: completedItems.length,
                itemBuilder: (BuildContext context, int index){
                  return ListTile(
                    leading: Icon(Icons.check),
                    title: Text("${completedItems[index].name}", style: TextStyle(fontSize: 16))
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
            child: Icon(CustomIcons.content_copy),
            backgroundColor: Colors.green,
            label: "Copy to new",
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {},
          ),
          SpeedDialChild(
            child: Icon(Icons.picture_as_pdf),
            backgroundColor: Colors.red,
            label: "Export as PDF",
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {},
          ),
        ],
      ),
    );
  }

}