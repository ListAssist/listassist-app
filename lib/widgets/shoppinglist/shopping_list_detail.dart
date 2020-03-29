import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:listassist/assets/custom_colors.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/achievements.dart';
import 'package:listassist/services/connectivity.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:listassist/widgets/shoppinglist/prize_dialog.dart';
import 'package:listassist/widgets/shoppinglist/search_items_view_new.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listassist/services/camera.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListDetail extends StatefulWidget {
  final int index;
  final bool isGroup;
  ShoppingListDetail({this.index, this.isGroup = false});

  @override
  _ShoppingListDetail createState() => _ShoppingListDetail();
}

class _ShoppingListDetail extends State<ShoppingListDetail> {
  ShoppingList list;
  User _user;
  String uid = "";
  bool useCache = false;

  //Spamschutz z.B. beim Löschen
  //TODO: Getter length called on null bills
  //TODO: Check if buttonsDisabled is correctly implemented because it wasnt in the completed detail widget
  bool _buttonsDisabled = false;

  Timer _debounce;
  int _debounceTime = 1000;

  int _boughtItemCount = 0;

  var prefs;
  bool showPrices = false;

  initSharedPreferences() async{
    prefs = await SharedPreferences.getInstance();
    showPrices = prefs.getBool("showPrices");
    print(showPrices.toString() + " aus SharedPrefs ausgelesen [showPrices]");
    if(showPrices == null) showPrices = false;
    setState(() {});
  }

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

  void itemChangeMultiple({bool val = true, List<int> indecesToCheck, List<double> prices}) async {
    setState(() {
      for (int i = 0; i < indecesToCheck.length; i++) {
        list.items[indecesToCheck[i]].bought = val;
        list.items[indecesToCheck[i]].price = prices[i];
      }
    });

    try {
      await databaseService.updateList(uid, list, widget.isGroup);
    } catch (e) {
      InfoOverlay.showErrorSnackBar("Fehler beim aktualisieren der Einkaufsliste");
    }
  }

  ScrollController _hideButtonController;
  bool _isVisible;

  @override
  initState(){
    initSharedPreferences();
    _isVisible = true;
    _hideButtonController = ScrollController();
    _hideButtonController.addListener((){
//      print('scrolling = ${_hideButtonController.position.isScrollingNotifier.value}');
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
    _user = Provider.of<User>(context);
    if (!useCache) {
      if(widget.isGroup){
        list = Provider.of<ShoppingList>(context);
      }else {
        list = Provider.of<List<ShoppingList>>(context)[widget.index];
      }
      if(list != null && list.items.isNotEmpty) {
        _boughtItemCount = list.items.map((e) => e.bought ? 1 : 0).reduce((a, b) => a + b);
      }
    }
    if(widget.isGroup){
      uid = Provider.of<List<Group>>(context)[widget.index].id;
    }else {
      uid = Provider.of<User>(context).uid;
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: _user.settings["theme"] == "Blau" ? Theme.of(context).colorScheme.primary : CustomColors.shoppyGreen,
        title: Text(list == null ? "" : list.name),
        flexibleSpace: _user.settings["theme"] == "Verlauf" ? Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: <Color>[
                        CustomColors.shoppyBlue,
                        CustomColors.shoppyLightBlue,
                      ])
              )) : Container(),
        actions: <Widget>[
          PopupMenuButton<ListAction>(
            onSelected: (ListAction result) async {
            if (result == ListAction.edit) {
              _showRenameDialog();
            } else if (result == ListAction.delete) {
              _showDeleteDialog();
            } else if (result == ListAction.complete) {
              _showCompleteDialog();
            } else if (result == ListAction.showPrices) {
              setState(() {
                showPrices = !showPrices;
              });
              prefs.setBool("showPrices", showPrices);
              print(showPrices.toString() + " in SharedPrefs geschrieben");
            }
          },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<ListAction>>[
              PopupMenuItem<ListAction>(
                value: ListAction.complete,
                enabled: _boughtItemCount > 0,
                child: Text('Abschließen')
              ),
              PopupMenuItem<ListAction>(
                  value: ListAction.showPrices,
                  child: Text(showPrices ? 'Preise ausblenden' : 'Preise anzeigen')
              ),
              PopupMenuItem<ListAction>(
                value: ListAction.edit,
                child: Text('Umbenennen')
              ),
              PopupMenuItem<ListAction>(
                value: ListAction.delete,
                child: Text('Löschen')
              ),
            ],
          )
        ],
      ),
      body: list == null ? ShoppyShimmer() : list.items.isEmpty ? Center(child: Text("Die Liste hat noch keine Produkte", style: Theme.of(context).textTheme.title)) : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10.0),
            child: Text("$_boughtItemCount von ${list.items.length} Produkt${list.items.length > 1 ? "en" : ""} gekauft", style: Theme.of(context).textTheme.headline)
          ),
          Expanded(
              child: list.items.isNotEmpty
                  ? ListView.builder(
                  controller: _hideButtonController,
                  physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  itemCount: list.items.length,
                      itemBuilder: (BuildContext context, int index) {
                        String iconFileName = list.items[index].category.toLowerCase()
                            .replaceAll(RegExp("ü"), "ue")
                            .replaceAll(RegExp("ö"), "oe")
                            .replaceAll(RegExp("ä"), "ae")
                            .replaceAll(RegExp("ß"), "ss")
                            .replaceAll(RegExp(" & "), "_")
                            .replaceAll(RegExp("allgemein"), "fisch") + ".png";

                        return Container(
                            child: Card(
                              elevation: list.items[index].bought ? 0 : 2,
                              color: list.items[index].bought ? Colors.transparent : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              child: CheckboxListTile(
                                  value: list.items[index].bought,
                                  title: Text("${list.items[index].name}", style: null),
                                  //subtitle: list.items[index].count != null ? Text(list.items[index].count.toString() + "x") : Text("0x"),
                                  subtitle: list.items[index].count != null && list.items[index].count != 1 ? Text("${list.items[index].count.toString()}x | ${list.items[index].category}") : Text("${list.items[index].category}"),
                                  secondary: showPrices ? OutlineButton(
                                    //decoration: BoxDecoration(border: Border.all(width: 2), borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                    onPressed: () async {

                                      if (_debounce == null || !_debounce.isActive) {
                                        var erg = await showDialog(context: context, builder: (context) {
                                          return PrizeDialog(name: list.items[index].name, prize: list.items[index].price != null ? list.items[index].price : 0);
                                        });
                                        if(erg != null) {
                                          list.items[index].price = erg;
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
                                      child: list.items[index].price != null && list.items[index].price != 0.0 ? Text(list.items[index].price.toString() + " €") : Text("0 €"),
                                    ),
                                  ) : Image(image: AssetImage("assets/icons/" + iconFileName), width: 35,),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  onChanged: (bool val) {
                                    itemChange(val, index);
                                    list.items.sort((a, b) {
                                      if(a.bought && !b.bought) return 1;
                                      if(!a.bought && b.bought) return -1;
                                      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                                    });

                                  }),
                            ));
                      })
                  : Container()),
        ],
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Transform.scale(
                scale: 0.75,
                child: FloatingActionButton(
                  onPressed: () async {
                    bool connected = await connectivityService.testInternetConnection();
                    if (!connected) {
                      //I am NOT connected to the Internet
                      InfoOverlay.showErrorSnackBar("Kein Internetzugriff");
                      _buttonsDisabled = false;
                    } else {
                      InfoOverlay.showSourceSelectionSheet(context, callback: _startCameraScanner, arg: widget.index);
                    }
                  },
                  backgroundColor: Colors.white,
                  child: Icon(Icons.camera_alt, color: Colors.black),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SearchItemsViewNew(list: list, isGroup: widget.isGroup, groupid: uid)));
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  /// Starts up the camera scanner and awaits the output
  Future<void> _startCameraScanner(BuildContext context, ImageSource imageSource, int index) async {
    List<Map<String, dynamic>> indecesToCheck = await cameraService.getResultFromCameraScanner(context, imageSource, listIndex: index);
    if (indecesToCheck != null) {
      List<int> indices = [];
      List<double> prices = [];

      indecesToCheck.forEach((i) => indices.add(i["index"]));
      indecesToCheck.forEach((i) => prices.add(i["newPrice"]));

      itemChangeMultiple(indecesToCheck: indices, prices: prices);
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
                      List<Item> boughtItems = List.from(list.items);
                      boughtItems.removeWhere((item) => !item.bought);
                      achievementsService.checkListItems(_user, boughtItems);
                      achievementsService.checkListPrice(_user, boughtItems);
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

  Future<void> _showRenameDialog() async {
    TextEditingController _nameController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Liste umbenennen"),
          content: SingleChildScrollView(
              child: TextField(
                controller: _nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.all(3),
                  labelText: "Neuer Name",
                ),
              )
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
              child: Text("Umbenennen"),
              onPressed: () {
                databaseService.updateList(uid, ShoppingList(
                    id: list.id,
                    name: _nameController.text,
                    items: list.items), widget.isGroup)
                    .catchError((onError) {
                      InfoOverlay.showErrorSnackBar("Fehler beim Aktualisieren");
                      Navigator.of(context).pop();
                    })
                    .then((onSaved) {
                      InfoOverlay.showInfoSnackBar("Name aktualisiert");
                      Navigator.of(context).pop();
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

enum ListAction {
  edit, delete, complete, showPrices
}