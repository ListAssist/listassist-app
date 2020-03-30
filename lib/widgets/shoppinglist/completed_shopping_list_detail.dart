import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:listassist/assets/custom_colors.dart';
import 'package:listassist/assets/custom_icons.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/connectivity.dart';
import 'package:listassist/services/date_formatter.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:listassist/models/CompletedShoppingList.dart';
import 'bills.dart';

class CompletedShoppingListDetail extends StatefulWidget {
  final int index;
  final bool isGroup;
  CompletedShoppingListDetail({this.index, this.isGroup = false});

  @override
  _CompletedShoppingListDetailState createState() => _CompletedShoppingListDetailState();
}

class _CompletedShoppingListDetailState extends State<CompletedShoppingListDetail> {

  String _newName = "";

  //Spamschutz bei Buttons die länger brauchen
  bool _buttonsDisabled = false;
  bool _useCache = false;

  CompletedShoppingList list;
  String uid;

  bool _copyBought = true;
  bool _copyUnbought = false;

  @override
  Widget build(BuildContext context) {
    if (!_useCache) {
      if(widget.isGroup){
        list = Provider.of<CompletedShoppingList>(context);
      }else {
        list = Provider.of<List<CompletedShoppingList>>(context)[widget.index];
      }
    }
    if(widget.isGroup){
      uid = Provider.of<List<Group>>(context)[widget.index].id;
    }else {
      uid = Provider.of<User>(context).uid;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Provider.of<User>(context).settings["theme"] == "Blau" ? Theme.of(context).colorScheme.primary : CustomColors.shoppyGreen,
        title: Text(list == null ? "" : list.name),
        flexibleSpace: Provider.of<User>(context).settings["theme"] == "Verlauf" ? Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: <Color>[
                      CustomColors.shoppyBlue,
                      CustomColors.shoppyLightBlue,
                    ])
            )) : Container(),
      ),
      body: list == null ? ShoppyShimmer() : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(10.0),
              alignment: Alignment.center,
              child: Text("Einkauf am ${DateFormatter.getDate(list.completed.toDate())} erledigt", style: Theme.of(context).textTheme.headline)
          ),
          Container(
              padding: EdgeInsets.all(10.0),
              alignment: Alignment.center,
              child: Text("Gekaufte Produkte", style: Theme.of(context).textTheme.subhead)
          ),
          Expanded(child: buildItemList(list.completedItems)),
          Container(
              padding: EdgeInsets.all(10.0),
              alignment: Alignment.center,
              child: Text("Nicht gekaufte Produkte", style: Theme.of(context).textTheme.subhead)
          ),
          Expanded(child: buildItemList(list.uncompletedItems)),
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
            child: Icon(Icons.list),
            backgroundColor: (list?.bills != null && list.bills.isNotEmpty) ? Colors.blue : Colors.grey,
            label: "Rechnungen",
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: (list?.bills != null && list.bills.isNotEmpty) ? () {
              //TODO: Bills Widgets for groups and camera scanner for groups
              Navigator.push(context, MaterialPageRoute(builder: (context) => Bills(index: widget.index)));
            } : null,
          ),
          SpeedDialChild(
            child: Icon(CustomIcons.content_copy),
            backgroundColor: Colors.green,
            label: "Kopieren",
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () async {
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
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.delete),
            backgroundColor: Colors.red,
            label: "Löschen",
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: _showDeleteDialog
          ),
        ],
      ),
    );
  }

  ListView buildItemList(List<Item> items) {
    if(items == null || items.isEmpty){
      return ListView();
    }
    return ListView.builder(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index){
        return ListTile(
          trailing: items[index].price != null ? Text("${items[index].price} €") : null,
          title: Text("${items[index].name}", style: TextStyle(fontSize: 16)),
          subtitle: items[index].count != null ? Text(items[index].count.toString() + "x") : Text("0x"),
        );
      }
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
                  _useCache = true;
                  list = CompletedShoppingList(
                    id: list.id,
                    created: list.created,
                    name: list.name,
                    completedItems: list.completedItems,
                    allItems: list.allItems,
                    completed: list.completed,
                    uncompletedItems: list.uncompletedItems,
                    bills: list.bills
                  );

                  bool connected = await connectivityService.testInternetConnection();
                  if (!connected) {
                    //I am NOT connected to the Internet
                    InfoOverlay.showErrorSnackBar("Kein Internetzugriff");
                    _buttonsDisabled = false;
                    _useCache = false;
                  } else {
                    //I am connected to the Internet
                    databaseService.deleteList(uid, list.id, widget.isGroup).catchError((_) {
                      InfoOverlay.showErrorSnackBar("Fehler beim Löschen der Einkaufsliste");
                      _useCache = false;
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