import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:listassist/models/CompletedShoppingList.dart' as model;
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/connectivity.dart';
import 'package:listassist/services/date_formatter.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:provider/provider.dart';
import 'completed_shopping_list_detail.dart';


class CompletedShoppingList extends StatefulWidget {
  final int index;
  final bool isGroup;
  final int groupIndex;
  CompletedShoppingList({this.index, this.isGroup = false, this.groupIndex = 0});

  @override
  _CompletedShoppingListState createState() => _CompletedShoppingListState();
}

class _CompletedShoppingListState extends State<CompletedShoppingList> {
  String uid;
  model.CompletedShoppingList list;

  bool _buttonsDisabled = false;
  String _newName = "";

  bool _copyBought = true;
  bool _copyUnbought = false;

  @override
  Widget build(BuildContext context) {
    list = Provider.of<List<model.CompletedShoppingList>>(context)[this.widget.index];
    if(this.widget.isGroup) {
      uid = Provider.of<List<Group>>(context)[this.widget.groupIndex].id;
    }else {
      uid = Provider.of<User>(context).uid;
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => list != null ? Navigator.push(
        context,
        this.widget.isGroup ?
        MaterialPageRoute(builder: (context) {
          return list != null ? StreamProvider<model.CompletedShoppingList>.value(
              value: databaseService.streamCompletedListFromGroup(uid, list.id),
              child: CompletedShoppingListDetail(index: this.widget.groupIndex, isGroup: true)
          ) : null;
        }) :
        MaterialPageRoute(builder: (context) => CompletedShoppingListDetail(index: this.widget.index))
      ) : null,
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
                    Text("Kopieren"),
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
        // Edit
        if(picked == 0) {
            if(!_buttonsDisabled) {
              _buttonsDisabled = true;
              bool connected = await connectivityService
                  .testInternetConnection();
              if (connected) {
                ShoppingList newList;
                bool res = await _showCreateCopyDialog();
                if (!res) {
                  _buttonsDisabled = false;
                  return;
                }
                if (_newName != null && _newName != "" && _newName.trim() != "") {
                  newList = list.createNewCopy(_newName, _copyBought, _copyUnbought);
                } else {
                  newList = list.createNewCopy(null, _copyBought, _copyUnbought);
                }

                databaseService.createList(uid, newList, widget.isGroup).then((onComplete) {
                  InfoOverlay.showInfoSnackBar("Einkaufsliste wurde erfolgreich kopiert");
                  _buttonsDisabled = false;
                });
              } else {
                InfoOverlay.showErrorSnackBar("Kein Internetzugriff");
                _buttonsDisabled = false;
              }
            }
          // Delete
        }else if(picked == 1) {
          _showDeleteDialog();
        }
      },
      child: Container(
        padding: EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(list.name, style: Theme.of(context).textTheme.title),
              Text("Erledigt am ${DateFormatter.getDate(list.completed.toDate())}")
            ],
          ),
        ),
      )
    );
  }

  Future<void> _showDeleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Einkaufsliste löschen"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(
                    text: TextSpan(
                        style: new TextStyle(
                          color: Theme.of(context).textTheme.title.color,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: "Sind Sie sicher, dass Sie die Einkaufsliste "),
                          TextSpan(
                              text: "${list.name}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: " löschen möchten?")
                        ]))
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
              child: Text("Löschen"),
              onPressed: () {
                String name = list.name;
                databaseService.deleteList(uid, list.id, widget.isGroup).catchError((_) {
                  InfoOverlay.showErrorSnackBar("Fehler beim Löschen der Einkaufsliste");
                }).then((_) {
                  InfoOverlay.showInfoSnackBar("Einkaufsliste $name gelöscht");
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showCreateCopyDialog() async {
    TextEditingController _controller = TextEditingController();
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Einkaufsliste kopieren"),
          content: SingleChildScrollView(
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return ListBody(
                      children: <Widget>[
                        TextField(
                          controller: _controller,
                          decoration: new InputDecoration(
                              hintText: "Neuer Einkaufslistenname"
                          ),
                          keyboardType: TextInputType.text,
                        ),
                        CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text("Gekaufte Produkte"),
                          value: _copyBought,
                          onChanged: (bool val) {
                            setState(() {
                              _copyBought = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text("Nicht gekaufte Produkte"),
                          value: _copyUnbought,
                          onChanged: (bool val) {
                            setState(() {
                              _copyUnbought = val;
                            });
                          },
                        )
                      ],
                    );
                  }
              )
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.red,
              child: Text("Abbrechen"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
                child: Text("Neue Einkaufsliste erstellen"),
                onPressed: () {
                  if(!(_copyBought || _copyUnbought)) {
                    InfoOverlay.showErrorSnackBar("Wählen Sie mindestens eine zu kopierende Kategorie aus");
                    return;
                  }
                  _newName = _controller.text;
                  Navigator.of(context).pop(true);
                }
            ),
          ],
        );
      },
    );
  }

}