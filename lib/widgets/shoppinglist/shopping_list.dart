import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:listassist/widgets/shoppinglist/shopping_list_detail.dart';
import 'package:listassist/models/ShoppingList.dart' as model;
import 'package:provider/provider.dart';


class ShoppingList extends StatelessWidget {
  final int index;
  ShoppingList({this.index});

  @override
  Widget build(BuildContext context) {
    model.ShoppingList list = Provider.of<List<model.ShoppingList>>(context)[this.index];
//    print(list);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ShoppingListDetail(index: this.index)),
      ),
      onLongPressStart: (details) async {
        RenderBox overlay = Overlay.of(context).context.findRenderObject();
        dynamic picked = await showMenu(
          context: context,
          position: RelativeRect.fromRect(
              details.globalPosition & Size(10, 10), // smaller rect, the touch area
              Offset.zero & overlay.semanticBounds.size   // Bigger rect, the entire screen
          ),
          items: <PopupMenuEntry>[
            PopupMenuItem(
              value: 0,
              child: Row(
                children: <Widget>[
                  Icon(Icons.edit),
                  Text("Bearbeiten"),
                ],
              ),
            ),
            PopupMenuItem(
              value: 1,
              child: Row(
                children: <Widget>[
                  Icon(Icons.delete,),
                  Text("Löschen"),
                ],
              ),
            )
          ]
        );
        print(picked);
      },
      child: Container(
        padding: EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(list.name, style: Theme.of(context).textTheme.title),
              Text(list.items.length > 0 ? "${list.items.map((e) => e.bought ? 1 : 0).reduce((a, b) => a + b)}/${list.items.length} eingekauft" : "Keine Produkte vorhanden")
            ],
          ),
        ),
      )
    );
  }
}