import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/widgets/shoppinglist/edit_shopping_list.dart';
import 'package:listassist/widgets/shoppinglist/search_items_view.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listassist/services/camera.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:listassist/widgets/camera-scanner/camera_scanner.dart';

class ShoppingListDetail extends StatefulWidget {
  final int index;

  ShoppingListDetail({this.index});

  @override
  _ShoppingListDetail createState() => _ShoppingListDetail();
}

class _ShoppingListDetail extends State<ShoppingListDetail> {
  ShoppingList list;
  String uid = "";
  bool useCache = false;

  Timer _debounce;
  int _debounceTime = 1500;

  void itemChange(bool val, int index) {
    setState(() {
      list.items[index].bought = val;
    });
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: _debounceTime), () {
      if (list != null && uid != null || uid.length > 0) {
        databaseService.updateList(uid, list).then((onUpdate) {
          print("Saved items");
        }).catchError((onError) {
          InfoOverlay.showErrorSnackBar(
              "Fehler beim aktualisieren der Einkaufsliste");
        });
      }
    });
  }

  void itemChangeMultiple({bool val = true, List<int> indecesToCheck}) async {
    setState(() {
      for (int i = 0; i < indecesToCheck.length; i++) {
        list.items[indecesToCheck[i]].bought = val;
      }
    });

    try {
      await databaseService.updateList(uid, list);
    } catch (e) {
      InfoOverlay.showErrorSnackBar(
          "Fehler beim aktualisieren der Einkaufsliste");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ShoppingList> lists = Provider.of<List<ShoppingList>>(context);
    if (!useCache) {
      list = Provider.of<List<ShoppingList>>(context)[widget.index];
    }
    uid = Provider.of<User>(context).uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(list.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditShoppingList(index: widget.index)),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(10.0),
              child: list.items.isNotEmpty
                  ? Text(
                      "${list.items.map((e) => e.bought ? 1 : 0).reduce((a, b) => a + b)} von ${list.items.length} Produkten gekauft",
                      style: Theme.of(context).textTheme.headline)
                  : Center(
                      child:
                          Text("Die Einkaufsliste hat noch keine Produkte"))),
          Expanded(
              child: list.items.isNotEmpty
                  ? ListView.builder(
                      itemCount: list.items.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            child: CheckboxListTile(
                                value: list.items[index].bought,
                                title: Text("${list.items[index].name}",
                                    style: list.items[index].bought
                                        ? TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            decorationThickness: 3)
                                        : null),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onChanged: (bool val) {
                                  itemChange(val, index);
                                }));
                      })
                  : Container()),
        ],
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 80.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                child: Icon(Icons.add),
                backgroundColor: Colors.green,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchItemsView(
                              lists.elementAt(widget.index).id)));
                },
              ),
            ),
          ),
          SpeedDial(
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
                  labelBackgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                  label: "Complete",
                  labelStyle: TextStyle(
                      fontSize: 18.0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black),
                  onTap: _showCompleteDialog),
              SpeedDialChild(
                  child: Icon(Icons.delete),
                  backgroundColor: Colors.red,
                  labelBackgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                  label: "Delete",
                  labelStyle: TextStyle(
                      fontSize: 18.0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black),
                  onTap: _showDeleteDialog),
              SpeedDialChild(
                child: Icon(Icons.camera),
                backgroundColor: Colors.blue,
                label: "Image Check",
                labelBackgroundColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                labelStyle: TextStyle(
                    fontSize: 18.0,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
                onTap: () => InfoOverlay.showSourceSelectionSheet(context,
                    callback: _startCameraScanner, arg: widget.index),
              )
            ],
          ),
        ],
      ),
    );
  }

  /// Starts up the camera scanner and awaits the output
  Future<void> _startCameraScanner(
      BuildContext context, ImageSource imageSource, int index) async {
    List<int> indecesToCheck = await cameraService
        .getResultFromCameraScanner(context, imageSource, listIndex: index);
    if (indecesToCheck != null) {
      itemChangeMultiple(indecesToCheck: indecesToCheck);
    }
    Navigator.pop(context);
  }

  Future<void> _showCompleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Einkaufsliste abschließen"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(
                    text: TextSpan(
                        style: TextStyle(
                          color: Theme.of(context).textTheme.title.color,
                        ),
                        children: <TextSpan>[
                      TextSpan(
                          text: "Sind Sie sicher, dass Sie die Einkaufsliste "),
                      TextSpan(
                          text: "${list.name}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: " abschließen möchten?")
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
              child: Text("Abschließen"),
              onPressed: () {
                useCache = true;
                list = ShoppingList(
                  id: list.id,
                  created: list.created,
                  name: list.name,
                  items: list.items,
                );
                databaseService.completeList(uid, list).catchError((_) {
                  InfoOverlay.showErrorSnackBar(
                      "Fehler beim Abschließen der Einkaufsliste");
                  useCache = false;
                }).then((_) {
                  InfoOverlay.showInfoSnackBar(
                      "Einkaufsliste ${list.name} abgeschlossen");
                  Navigator.of(context).pop();
                  Navigator.of(this.context).pop();
                });
              },
            ),
          ],
        );
      },
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
                useCache = true;
                list = ShoppingList(
                  id: list.id,
                  created: list.created,
                  name: list.name,
                  items: list.items,
                );
                databaseService.deleteList(uid, list.id).catchError((_) {
                  InfoOverlay.showErrorSnackBar(
                      "Fehler beim Löschen der Einkaufsliste");
                  useCache = false;
                }).then((_) {
                  InfoOverlay.showInfoSnackBar(
                      "Einkaufsliste ${list.name} gelöscht");
                  Navigator.of(context).pop();
                  Navigator.of(this.context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
