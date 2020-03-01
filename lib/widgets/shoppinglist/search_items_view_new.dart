import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listassist/models/Product.dart';
import 'package:listassist/models/Recipe.dart';
import 'package:listassist/models/ScannedShoppinglist.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/camera.dart';
import 'package:listassist/services/connectivity.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:listassist/widgets/shoppinglist/item_counter.dart';
import 'package:listassist/widgets/shoppinglist/speech_dialog.dart';
import 'package:provider/provider.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'add_shopping_list.dart';

class SearchItemsViewNew extends StatefulWidget {
  final ShoppingList list;
  final Recipe recipe;

  SearchItemsViewNew({this.list, this.recipe});

  @override
  _SearchItemsViewNew createState() => _SearchItemsViewNew();
}

class _SearchItemsViewNew extends State<SearchItemsViewNew>  with TickerProviderStateMixin{
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  TextEditingController _searchController = TextEditingController();
  TabController _tabController;

  List<ScannedShoppingList> scannedLists = [];

  var _listOrRecipe;
  bool _isList;

  User _user;

  Algolia algolia = Application.algolia;
  bool _searching = false;

  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  String resultText = "";

  Timer _debounce;
  int _debounceTime = 2000;

  List<dynamic> _products = [];
  List<Product> _popularProducts = [];

  bool initialized = false;

  _searchProducts(String search) async {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () async {
      if (await connectivityService.testInternetConnection()) {
        _products = [];
        _searching = true;
        setState(() {});

        AlgoliaQuery query = algolia.instance.index('products').search(search);
        AlgoliaQuerySnapshot snap = await query.getObjects();
        List<dynamic> hits = List<dynamic>();
        snap.hits.forEach((h) => {hits.add(h.data)});

        _products = hits;
        _searching = false;
        setState(() {});
      } else {
        _products = [];
        InfoOverlay.showErrorSnackBar("Kein Internetzugriff");
      }
    });
  }

  _addItem(Product product) {
    _listOrRecipe.addItem(product.name, product.category);
    setState(() {});
    _requestDatabaseUpdate();
  }

  _addCount(String itemName) {
    _listOrRecipe.changeItemCount(itemName, 1);
    setState(() {});
    _requestDatabaseUpdate();
  }

  _subtractCount(String itemName) {
    if (_listOrRecipe.getItemCount(itemName) == 1) {
      _listOrRecipe.removeItem(itemName);
      setState(() {});
      _requestDatabaseUpdate();
    } else {
      _listOrRecipe.changeItemCount(itemName, -1);
      setState(() {});
      _requestDatabaseUpdate();
    }
  }

  // Updated mit Debounce die Einkaufsliste in der Datenbank
  _requestDatabaseUpdate() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: _debounceTime), () {
      if (_listOrRecipe != null && _user.uid != null || _user.uid.length > 0) {
        print(_listOrRecipe.id);

        _isList
            ? databaseService.updateList(_user.uid, _listOrRecipe).then((value) => {print("Liste wurde erfolgreich upgedated")}).catchError((_) => {print(_.toString())})
            : databaseService.updateRecipe(_user.uid, _listOrRecipe).then((value) => {print("Rezept wurde erfolgreich upgedated")}).catchError((_) => {print(_.toString())});
      }
    });
  }

  _subtractCountUserInput() {
    if (_listOrRecipe.getItemCount(_searchController.text) == 1) {
      _listOrRecipe.removeItem(_searchController.text);
      setState(() {});
      _requestDatabaseUpdate();
    } else {
      _listOrRecipe.changeItemCount(_searchController.text, -1);
      setState(() {});
      _requestDatabaseUpdate();
    }
  }

  Future<void> showSpeechRecognitionDialog() async {
    resultText = await showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return SpeechDialog(dialogContext: buildContext);
        });
    if (resultText == null) {
      resultText = "";
    } else {
      var resultProducts = resultText.trim().split(" und ");
      resultProducts.forEach((p) {
        if (_listOrRecipe.hasItem(p)) {
          _addCount(p);
        } else {
          _addItem(new Product(name: p, category: "Spracherkennung"));
        }
      });
    }
    setState(() {});
  }

  @override
  void initState() {
    if (widget.list != null) {
      _listOrRecipe = widget.list;
      _isList = true;
    } else {
      _listOrRecipe = widget.recipe;
      _isList = false;
    }

    _tabController = new TabController(length: 3, initialIndex: _listOrRecipe.items.length > 0 ? 0 : 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
          key: _scaffoldKey,
          floatingActionButton: Stack(children: [
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                child: Icon(Icons.check),
                onPressed: () {
                  Navigator.pop(context);
                },
                backgroundColor: Colors.green,
              ),
            ),
           /* Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(bottom: 60.0),
                child: Transform.scale(
                  scale: 0.75,
                  child: FloatingActionButton(
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                    ),
                    onPressed: () async{
                      await connectivityService.testInternetConnection() ? InfoOverlay.showSourceSelectionSheet(context, callback: _startCameraScanner, arg: null)
                          : InfoOverlay.showErrorSnackBar("Kein Internetzugriff");
                    },
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),*/
          ]),
          body: Column(children: <Widget>[
            Container(
              height: 120.0,
              child: Stack(
                children: <Widget>[
                  Container(
                    color: Theme.of(context).primaryColor,
                    width: MediaQuery.of(context).size.width,
                    height: 120.0,
                  ),
                  Positioned(
                    top: 50.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(45.0), color: Colors.white),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(fontSize: 20),
                                onChanged: (text) async {
                                  //_products.clear();
                                  //_products = [];
                                  setState(() {});
                                  if (text.length == 0) {
                                    return;
                                  }
                                  await _searchProducts(text);
                                  setState(() {});
                                },
                                decoration: InputDecoration(border: InputBorder.none, hintText: "Produkt Suchen", contentPadding: EdgeInsets.all(17)),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.mic,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () async {
                                await showSpeechRecognitionDialog();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            _searchController.text.length == 0
                ? Container(
                    color: Theme.of(context).primaryColor,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      tabs: [Tab(text: _isList ? "Auf Liste" : "Auf Rezept"), Tab(text: "Beliebt"), Tab(text: "Kategorien")],
                    ),
                  )
                : Container(),
            _searchController.text.length == 0
                ? Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        Container(
                            child: _listOrRecipe.items.length > 0 ? MediaQuery.removePadding(
                                removeTop: true,
                                context: context,
                                child: ListView.separated(
                                  itemCount: _listOrRecipe.items.length,
                                  separatorBuilder: (ctx, i) => Divider(
                                    indent: 70,
                                    endIndent: 10,
                                    color: Colors.grey,
                                  ),
                                  itemBuilder: (context, index) {
                                    _subtract() {
                                      _subtractCount(_listOrRecipe.items[index].name);
                                    }

                                    return Container(
                                      height: 65,
                                      child: ListTile(
                                        leading: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(Icons.local_dining),
                                        ),
                                        title: Text(_listOrRecipe.items[index].name),
                                        subtitle: Text(_listOrRecipe.items[index].category),
                                        trailing: ItemCounter(count: _listOrRecipe.items[index].count, subtractCount: _subtract),
                                        onTap: () {
                                          _addCount(_listOrRecipe.items[index].name);
                                        },
                                      ),
                                    );
                                  },
                                )): Center(child: Text("keko"))), //erster tab

                        FutureBuilder(
                            future: databaseService.getPopularProducts(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return ShoppyShimmer();
                              }

                              return MediaQuery.removePadding(
                                  removeTop: true,
                                  context: context,
                                  child: ListView.separated(
                                    itemCount: snapshot.data.length,
                                    separatorBuilder: (ctx, i) => Divider(
                                      indent: 70,
                                      endIndent: 10,
                                      color: Colors.grey,
                                    ),
                                    itemBuilder: (context, index) {
                                      _subtract() {
                                        _subtractCount(snapshot.data[index].name);
                                      }

                                      return Container(
                                        height: 65,
                                        child: ListTile(
                                          leading: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.local_dining),
                                          ),
                                          title: Text(snapshot.data[index].name),
                                          subtitle: Text(snapshot.data[index].category),
                                          trailing: _listOrRecipe.hasItem(snapshot.data[index].name)
                                              ? ItemCounter(count: _listOrRecipe.items.firstWhere((i) => i.name == snapshot.data[index].name).count, subtractCount: _subtract)
                                              : Container(
                                                  width: 0,
                                                  height: 0,
                                                ),
                                          onTap: () {
                                            if (!_listOrRecipe.hasItem(snapshot.data[index].name)) {
                                              _addItem(new Product(name: snapshot.data[index].name, category: snapshot.data[index].category));
                                            } else {
                                              _addCount(snapshot.data[index].name);
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  ));
                            }),
                        Column(
                          children: <Widget>[
                            Text(resultText),
                          ],
                        )
                      ],
                    ),
                  )
                : Expanded(
                    child: MediaQuery.removePadding(
                        removeTop: true,
                        context: context,
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 70,
                              child: ListTile(
                                leading: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.shopping_cart, color: _listOrRecipe.hasItem(_searchController.text) ? Theme.of(context).primaryColor : null),
                                ),
                                title: Text(_searchController.text),
                                subtitle: Text("Selbst erstellt"),
                                trailing: _listOrRecipe.hasItem(_searchController.text)
                                    ? ItemCounter(count: _listOrRecipe.items.firstWhere((i) => i.name == _searchController.text).count, subtractCount: _subtractCountUserInput)
                                    : Container(
                                        width: 0,
                                        height: 0,
                                      ),
                                onTap: () {
                                  if (!_listOrRecipe.hasItem(_searchController.text)) {
                                    _addItem(new Product(name: _searchController.text, category: "Selbst erstellt"));
                                  } else {
                                    _addCount(_searchController.text);
                                  }
                                },
                              ),
                            ),
                            _searching == false
                                ? _products.length > 0
                                    ? Expanded(
                                        child: ListView.separated(
                                          itemCount: _products.length,
                                          separatorBuilder: (ctx, i) => Divider(
                                            indent: 70,
                                            endIndent: 10,
                                            color: Colors.grey,
                                          ),
                                          itemBuilder: (context, index) {
                                            _subtract() {
                                              _subtractCount(_products[index]["name"]);
                                            }

                                            int count = 0;

                                            if (_listOrRecipe.hasItem(_products[index]["name"])) {
                                              count = _listOrRecipe.items.firstWhere((i) => i.name == _products[index]["name"]).count;
                                            }

                                            return Container(
                                              height: 65,
                                              child: ListTile(
                                                leading: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(Icons.local_dining, color: _listOrRecipe.hasItem(_products[index]["name"]) ? Theme.of(context).primaryColor : null),
                                                ),
                                                title: Text(_products[index]["name"]),
                                                subtitle: Text(_products[index]["category"]),
                                                trailing: _listOrRecipe.hasItem(_products[index]["name"])
                                                    ? ItemCounter(count: count, subtractCount: _subtract)
                                                    : Container(
                                                        width: 0,
                                                        height: 0,
                                                      ),
                                                onTap: () {
                                                  if (!_listOrRecipe.hasItem(_products[index]["name"])) {
                                                    _addItem(new Product(name: _products[index]["name"], category: _products[index]["category"]));
                                                  } else {
                                                    _addCount(_products[index]["name"]);
                                                  }
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(top: 50.0, bottom: 15.0),
                                            child: Icon(
                                              Icons.sentiment_dissatisfied,
                                              size: 50,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                          Text(
                                            "Keine Produkte gefunden",
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      )
                                : ShoppyShimmer(),
                          ],
                        )),
                  )
          ])),
    );
  }


  /// Starts up the camera scanner and awaits output to process
  Future<void> _startCameraScanner(BuildContext context, ImageSource imageSource, ShoppingList list) async {
    ScannedShoppingList scannedShoppingList = await cameraService.getResultFromCameraScanner(context, imageSource, addToList: list);
    if (scannedShoppingList != null) {
      setState(() {
        scannedLists.add(scannedShoppingList);
      });
    }

    Navigator.pop(context);
  }

}
