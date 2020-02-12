import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/connectivity.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:listassist/widgets/shoppinglist/edit_shopping_list.dart';
import 'package:listassist/widgets/shoppinglist/prize_dialog.dart';
import 'package:listassist/widgets/shoppinglist/search_items_view.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listassist/services/camera.dart';
import 'package:listassist/services/info_overlay.dart';

class ShoppingListDetail extends StatefulWidget {
  final int index;
  final bool isGroup;
  ShoppingListDetail({this.index, this.isGroup = false});

  @override
  _ShoppingListDetail createState() => _ShoppingListDetail();
}

class _ShoppingListDetail extends State<ShoppingListDetail> {
  ShoppingList list;
  String uid = "";
  bool useCache = false;

  //Spamschutz z.B. beim Löschen
  bool _buttonsDisabled = false;

  Timer _debounce;
  int _debounceTime = 1000;

  int _boughtItemCount = 0;

  void itemChange(bool val, int index) {
    setState(() {
      list.items[index].bought = val;
    });
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: _debounceTime), () {
      if (list != null && uid != null || uid.length > 0) {
        databaseService.updateList(uid, list, widget.isGroup).then((onUpdate) {
          print("Saved items");
        }).catchError((onError) {
          InfoOverlay.showErrorSnackBar("Fehler beim aktualisieren der Einkaufsliste");
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
      await databaseService.updateList(uid, list, widget.isGroup);
    } catch (e) {
      InfoOverlay.showErrorSnackBar("Fehler beim aktualisieren der Einkaufsliste");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!useCache) {
      if(widget.isGroup){
        list = Provider.of<ShoppingList>(context);
      }else {
        list = Provider.of<List<ShoppingList>>(context)[widget.index];
      }
      _boughtItemCount = list.items.map((e) => e.bought ? 1 : 0).reduce((a, b) => a + b);
    }
    if(widget.isGroup){
      uid = Provider.of<List<Group>>(context)[widget.index].id;
    }else {
      uid = Provider.of<User>(context).uid;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(list == null ? "" : list.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              widget.isGroup ?
              MaterialPageRoute(builder: (context) {
                return StreamProvider<ShoppingList>.value(
                  value: databaseService.streamListFromGroup(uid, list.id),
                  child: EditShoppingList(index: widget.index, isGroup: true)
                );
              }) :
              MaterialPageRoute(builder: (context) => EditShoppingList(index: widget.index)),
            ),
          )
        ],
      ),
      body: list == null ? ShoppyShimmer() : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10.0),
            child: list.items.isNotEmpty
              ? Text("$_boughtItemCount von ${list.items.length} Produkt${list.items.length > 1 ? "en" : ""} gekauft", style: Theme.of(context).textTheme.headline)
              : Center(child: Text("Die Einkaufsliste hat noch keine Produkte"))),
          Expanded(
            child: list.items.isNotEmpty
              ? ListView.builder(
                physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                itemCount: list.items.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: CheckboxListTile(
                      value: list.items[index].bought,
                      title: Text("${list.items[index].name}", style: list.items[index].bought ? TextStyle(decoration: TextDecoration.lineThrough, decorationThickness: 3) : null),
                      subtitle: list.items[index].count != null ? Text(list.items[index].count.toString() + "x") : Text("0x"),
                      secondary: OutlineButton(
                        //decoration: BoxDecoration(border: Border.all(width: 2), borderRadius: BorderRadius.all(Radius.circular(5.0))),
                        onPressed: () async {

                          if (_debounce == null || !_debounce.isActive) {
                            var erg = await showDialog(context: context, builder: (context) {
                              return PrizeDialog(name: list.items[index].name, prize: list.items[index].prize != null ? list.items[index].prize : 0);
                            });
                            if(erg != null) {
                              list.items[index].prize = erg;
                              //hier wird bisschen getrickst HAHAH XD SRY SECZER WAR ZU FAUL
                              itemChange(list.items[index].bought, index);
                              setState(() {});
                              databaseService.updateList(uid, list, widget.isGroup).then((onUpdate) {
                                print("Saved items");
                              }).catchError((onError) {
                                InfoOverlay.showErrorSnackBar("Fehler beim aktualisieren der Einkaufsliste");
                              });
                            }
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(9.0),
                          child: list.items[index].prize != null ? Text(list.items[index].prize.toString() + " €") : Text("0 €"),
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool val) {
                        itemChange(val, index);
                      }));
                })
              : Container()),
        ],
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Colors.green,
              onPressed: () {
                Navigator.push(context,
                    widget.isGroup ?
                    MaterialPageRoute(builder: (context) =>
                      StreamProvider<ShoppingList>.value(
                        value: databaseService.streamListFromGroup(uid, list.id),
                        child: SearchItemsView(uid, true)
                      ))
                    : MaterialPageRoute(builder: (context) => SearchItemsView(list.id)));
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 75.0),
            child: SpeedDial(
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
                    labelBackgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white,
                    label: "Complete",
                    labelStyle: TextStyle(fontSize: 18.0, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    onTap: _showCompleteDialog),
                SpeedDialChild(
                    child: Icon(Icons.delete),
                    backgroundColor: Colors.red,
                    labelBackgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white,
                    label: "Delete",
                    labelStyle: TextStyle(fontSize: 18.0, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    onTap: _showDeleteDialog),
                SpeedDialChild(
                  child: Icon(Icons.camera),
                  backgroundColor: Colors.blue,
                  label: "Image Check",
                  labelBackgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white,
                  labelStyle: TextStyle(fontSize: 18.0, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                  onTap: () async {
                    bool connected = await connectivityService.testInternetConnection();
                    if (!connected) {
                      //I am NOT connected to the Internet
                      InfoOverlay.showErrorSnackBar("Kein Internetzugriff");
                      _buttonsDisabled = false;
                    } else {
                      InfoOverlay.showSourceSelectionSheet(context, callback: _startCameraScanner, arg: widget.index);
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Starts up the camera scanner and awaits the output
  Future<void> _startCameraScanner(BuildContext context, ImageSource imageSource, int index) async {
    List<int> indecesToCheck = await cameraService.getResultFromCameraScanner(context, imageSource, listIndex: index);
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
                      TextSpan(text: "Sind Sie sicher, dass Sie die Einkaufsliste "),
                      TextSpan(text: "${list.name}", style: TextStyle(fontWeight: FontWeight.bold)),
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
              onPressed: () async {
                if (!_buttonsDisabled) {
                  bool connected = await connectivityService.testInternetConnection();
                  if (!connected) {
                    //I am NOT connected to the Internet
                    InfoOverlay.showErrorSnackBar("Kein Internetzugriff");
                    _buttonsDisabled = false;
                  } else {
                    //I am connected to the Internet
                    _buttonsDisabled = true;
                    useCache = true;
                    list = ShoppingList(
                      id: list.id,
                      created: list.created,
                      name: list.name,
                      items: list.items,
                    );
                    databaseService.completeList(uid, list, widget.isGroup).catchError((_) {
                      InfoOverlay.showErrorSnackBar("Fehler beim Abschließen der Einkaufsliste");
                      useCache = false;
                      _buttonsDisabled = false;
                    }).then((_) {
                      InfoOverlay.showInfoSnackBar("Einkaufsliste ${list.name} abgeschlossen");
                      Navigator.of(context).pop();
                      Navigator.of(this.context).pop();
                    });
                  }
                }
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
                      TextSpan(text: "Sind Sie sicher, dass Sie die Einkaufsliste "),
                      TextSpan(text: "${list.name}", style: TextStyle(fontWeight: FontWeight.bold)),
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
              onPressed: () async {
                if (!_buttonsDisabled) {
                  _buttonsDisabled = true;
                  useCache = true;
                  list = ShoppingList(
                    id: list.id,
                    created: list.created,
                    name: list.name,
                    items: list.items,
                  );

                  bool connected = await connectivityService.testInternetConnection();
                  if (!connected) {
                    //I am NOT connected to the Internet
                    InfoOverlay.showErrorSnackBar("Kein Internetzugriff");
                    _buttonsDisabled = false;
                  } else {
                    //I am connected to the Internet
                    databaseService.deleteList(uid, list.id, widget.isGroup).catchError((_) {
                      InfoOverlay.showErrorSnackBar("Fehler beim Löschen der Einkaufsliste");
                      useCache = false;
                      _buttonsDisabled = false;
                    }).then((_) {
                      InfoOverlay.showInfoSnackBar("Einkaufsliste ${list.name} gelöscht");
                      Navigator.of(context).pop();
                      Navigator.of(this.context).pop();
                    });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
