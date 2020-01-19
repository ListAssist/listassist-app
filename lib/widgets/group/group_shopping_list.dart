import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/widgets/group/group_shopping_list_detail.dart';
import 'package:provider/provider.dart';


class GroupShoppingList extends StatelessWidget {
  final String id;
  final int index;
  GroupShoppingList({this.id, this.index});

  @override
  Widget build(BuildContext context) {
    return _GroupShoppingList(index: this.index);
  }
}

class _GroupShoppingList extends StatelessWidget {
  final int index;
  _GroupShoppingList({this.index});

  @override
  Widget build(BuildContext context) {
    ShoppingList list = Provider.of<List<ShoppingList>>(context)[this.index];
    Group group = Provider.of<List<Group>>(context)[this.index];

    return list == null ? SpinKitDoubleBounce(color: Colors.blue) : GestureDetector(
        behavior: HitTestBehavior.translucent,
        //FIXME: Invalid Arguments
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return StreamProvider<ShoppingList>.value(
                value: databaseService.streamListFromGroup(group.id, list.id),
                child: GroupShoppingListDetail()
            );
          }),
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
