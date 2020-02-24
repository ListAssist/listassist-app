import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/widgets/shoppinglist/edit_shopping_list.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listassist/services/camera.dart';
import 'package:listassist/services/info_overlay.dart';

class GroupShoppingListDetail extends StatefulWidget {

  final int index;
  GroupShoppingListDetail({this.index});

  @override
  _GroupShoppingListDetail createState() => _GroupShoppingListDetail();
}

class _GroupShoppingListDetail extends State<GroupShoppingListDetail> {
  ShoppingList list;
  String groupid = "";
  bool useCache = false;

  Timer _debounce;
  int _debounceTime = 1500;

  ScrollController _hideButtonController;
  bool _isVisible;

  void itemChange(bool val, int index) {
    setState(() {
      list.items[index].bought = val;
    });
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: _debounceTime), () {
      if (list != null && groupid != null || groupid.length > 0) {
        databaseService.updateList(groupid, list, true).then((onUpdate) {
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
      await databaseService.updateList(groupid, list, true);
    } catch (e) {
      InfoOverlay.showErrorSnackBar(
          "Fehler beim aktualisieren der Einkaufsliste");
    }
  }

  _scrollListener() {

  }

  @override
  initState(){
    _isVisible = true;
    _hideButtonController = ScrollController();
    _hideButtonController.addListener((){
      print('scrolling = ${_hideButtonController.position.isScrollingNotifier.value}');
      if(_hideButtonController.position.userScrollDirection == ScrollDirection.reverse){
        if(_isVisible == true) {
          /* only set when the previous state is false
             * Less widget rebuilds
             */
          print("**** ${_isVisible} up"); //Move IO away from setState
          setState((){
            _isVisible = false;
          });
        }
      } else {
        if(_hideButtonController.position.userScrollDirection == ScrollDirection.forward){
          if(_isVisible == false) {
            /* only set when the previous state is false
               * Less widget rebuilds
               */
            print("**** ${_isVisible} down"); //Move IO away from setState
            setState((){
              _isVisible = true;
            });
          }
        }
      }});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!useCache) {
      list = Provider.of<ShoppingList>(context);
    }
    groupid = Provider.of<List<Group>>(context)[widget.index].id;

    return list == null ? SpinKitDoubleBounce(color: Colors.blueAccent) : Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(list.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  StreamProvider<ShoppingList>.value(
                    value: databaseService.streamListFromGroup(groupid, list.id),
                    child: EditShoppingList(index: widget.index, isGroup: true))
                  ),
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
                  ? Text("${list.items.map((e) => e.bought ? 1 : 0).reduce((a, b) => a + b)} von ${list.items.length} Produkten gekauft", style: Theme.of(context).textTheme.headline)
                  : Center(child: Text("Die Einkaufsliste hat noch keine Produkte"))),
          Expanded(
              child: list.items.isNotEmpty
                  ? ListView.builder(
                  controller: _hideButtonController,
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
      floatingActionButton: Visibility(
        visible: _isVisible,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 80.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  child: Icon(Icons.add),
                  backgroundColor: Colors.green,
//                onPressed: () {
//                  Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (context) => SearchItemsView(
//                              lists.elementAt(widget.index).id)));
//                },
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
//                onTap: () => InfoOverlay.showSourceSelectionSheet(context,
//                    callback: _startCameraScanner, arg: widget.index),
                )
              ],
            ),
          ],
        ),
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
                databaseService.completeList(groupid, list, true).catchError((_) {
                  InfoOverlay.showErrorSnackBar("Fehler beim Abschließen der Einkaufsliste");
                  useCache = false;
                }).then((_) {
                  InfoOverlay.showInfoSnackBar("Einkaufsliste ${list.name} abgeschlossen");
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
                //FIXME: Error when deleting a list
                databaseService.deleteList(groupid, list.id, true).catchError((_) {
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
